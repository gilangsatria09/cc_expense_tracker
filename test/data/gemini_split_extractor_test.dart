import 'dart:convert';
import 'dart:typed_data';

import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/datasources/gemini_split_extractor.dart';
import 'package:cc_expense_tracker/domain/entities/extracted_split.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String geminiBody(String innerText) => jsonEncode({
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': innerText},
        ],
      },
    },
  ],
});

void main() {
  final image = Uint8List.fromList([1, 2, 3]);

  GeminiSplitExtractor extractor(
    MockClient client, {
    String? key = 'test-key',
  }) => GeminiSplitExtractor(client: client, apiKey: () => key);

  Future<List<ExtractedSplit>> run(GeminiSplitExtractor e) =>
      e.extract(imageBytes: image, mimeType: 'image/png');

  test(
    'sukses: parse JSON, kirim key di header & gambar sebagai base64',
    () async {
      late http.Request captured;
      final client = MockClient((req) async {
        captured = req;
        return http.Response(
          geminiBody(
            jsonEncode([
              {'nama': ' Budi ', 'subtotal': 35000},
              {'nama': 'Ani', 'subtotal': 20000.0},
              {'nama': '', 'subtotal': 1000},
              {'nama': 'Minus', 'subtotal': -5},
            ]),
          ),
          200,
        );
      });

      final result = await run(extractor(client));

      expect(result, const [
        ExtractedSplit(nama: 'Budi', subtotal: 35000),
        ExtractedSplit(nama: 'Ani', subtotal: 20000),
      ]);
      expect(captured.url.host, 'generativelanguage.googleapis.com');
      expect(
        captured.url.path,
        contains('gemini-3.5-flash-lite:generateContent'),
      );
      expect(captured.headers['x-goog-api-key'], 'test-key');
      expect(captured.url.query, isNot(contains('test-key')));

      final sent = jsonDecode(captured.body) as Map<String, dynamic>;
      final parts = sent['contents'][0]['parts'] as List;
      expect(parts[1]['inline_data']['mime_type'], 'image/png');
      expect(parts[1]['inline_data']['data'], base64Encode(image));
      expect(sent['generationConfig']['responseMimeType'], 'application/json');
      expect(sent['generationConfig'], isNot(contains('temperature')));
    },
  );

  test('array kosong dikembalikan apa adanya', () async {
    final client = MockClient(
      (_) async => http.Response(geminiBody('[]'), 200),
    );
    expect(await run(extractor(client)), isEmpty);
  });

  test('API key kosong: error tanpa memanggil jaringan', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('', 200);
    });
    for (final key in [null, '', '  ']) {
      await expectLater(
        run(extractor(client, key: key)),
        throwsA(
          isA<DomainException>().having(
            (e) => e.message,
            'message',
            contains('GEMINI_API_KEY'),
          ),
        ),
      );
    }
    expect(called, isFalse);
  });

  group('model tidak ditemukan (404)', () {
    const ok = '[{"nama":"Budi","subtotal":1000}]';

    MockClient fake({
      required Set<String> available,
      List<String>? paths,
      Map<String, dynamic>? listBody,
      int listStatus = 200,
    }) => MockClient((req) async {
      paths?.add(req.url.path);
      if (req.method == 'GET') {
        return http.Response(
          jsonEncode(listBody ?? {'models': []}),
          listStatus,
        );
      }
      final model = RegExp(
        r'models/([^:]+):',
      ).firstMatch(req.url.path)!.group(1);
      return available.contains(model)
          ? http.Response(geminiBody(ok), 200)
          : http.Response(
              jsonEncode({
                'error': {'code': 404, 'message': 'model not found'},
              }),
              404,
            );
    });

    test('model pertama 404: coba berikutnya sampai berhasil', () async {
      final paths = <String>[];
      final result = await run(
        extractor(fake(available: {'gemini-3.1-flash-lite'}, paths: paths)),
      );

      expect(result.single.nama, 'Budi');
      expect(paths, [
        '/v1beta/models/gemini-3.5-flash-lite:generateContent',
        '/v1beta/models/gemini-3.1-flash-lite:generateContent',
      ]);
    });

    test(
      'model yang berhasil diingat: panggilan berikutnya langsung ke sana',
      () async {
        final paths = <String>[];
        final e = extractor(
          fake(available: {'gemini-3.8-flash'}, paths: paths),
        );
        await run(e);
        paths.clear();
        await run(e);
        expect(paths, ['/v1beta/models/gemini-3.8-flash:generateContent']);
      },
    );

    test('GEMINI_MODEL dicoba paling dulu', () async {
      final paths = <String>[];
      final e = GeminiSplitExtractor(
        client: fake(available: {'gemini-custom'}, paths: paths),
        apiKey: () => 'k',
        modelOverride: () => ' gemini-custom ',
      );
      await run(e);
      expect(paths, ['/v1beta/models/gemini-custom:generateContent']);
    });

    test(
      'semua 404: pesan memuat model yang tersedia dari ListModels',
      () async {
        final e = extractor(
          fake(
            available: {},
            listBody: {
              'models': [
                {
                  'name': 'models/gemini-4-flash',
                  'supportedGenerationMethods': ['generateContent'],
                },
                {
                  'name': 'models/gemini-4-flash-tts',
                  'supportedGenerationMethods': ['generateContent'],
                },
                {
                  'name': 'models/gemini-embedding-001',
                  'supportedGenerationMethods': ['embedContent'],
                },
                {
                  'name': 'models/gemini-4-pro',
                  'supportedGenerationMethods': [
                    'generateContent',
                    'countTokens',
                  ],
                },
              ],
            },
          ),
        );

        await expectLater(
          run(e),
          throwsA(
            isA<DomainException>().having(
              (m) => m.message,
              'message',
              allOf(
                contains('tidak tersedia'),
                contains('gemini-3.5-flash-lite'),
                contains('gemini-4-flash, gemini-4-pro'),
                isNot(contains('tts')),
                isNot(contains('embedding')),
                contains('GEMINI_MODEL'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'ListModels ikut gagal: tetap pesan yang menyuruh mengisi GEMINI_MODEL',
      () async {
        await expectLater(
          run(extractor(fake(available: {}, listStatus: 500))),
          throwsA(
            isA<DomainException>().having(
              (m) => m.message,
              'message',
              allOf(contains('tidak tersedia'), contains('GEMINI_MODEL')),
            ),
          ),
        );
      },
    );

    test('kesalahan selain 404 tidak memicu pencobaan model lain', () async {
      final paths = <String>[];
      final client = MockClient((req) async {
        paths.add(req.url.path);
        return http.Response('{}', 429);
      });
      await expectLater(
        run(extractor(client)),
        throwsA(isA<DomainException>()),
      );
      expect(paths, hasLength(1));
    });
  });

  test('400/403 memuat alasan dari Google', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': {
            'code': 400,
            'message': 'API key not valid.\nPlease pass a valid key',
          },
        }),
        400,
      ),
    );
    await expectLater(
      run(extractor(client)),
      throwsA(
        isA<DomainException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('400'),
            contains('API key not valid. Please pass a valid key'),
          ),
        ),
      ),
    );
  });

  test('status error dipetakan ke pesan yang jelas', () async {
    Future<void> expectMessage(int status, String contains_) => expectLater(
      run(extractor(MockClient((_) async => http.Response('{}', status)))),
      throwsA(
        isA<DomainException>().having(
          (e) => e.message,
          'message',
          contains(contains_),
        ),
      ),
    );

    await expectMessage(429, 'Kuota');
    await expectMessage(403, 'API key');
    await expectMessage(500, '500');
  });

  test('respons tidak valid: pesan "tidak bisa dibaca"', () async {
    for (final body in [
      'bukan json',
      geminiBody('bukan json'),
      geminiBody('{"nama":"x"}'),
      geminiBody('[{"nama":"x"}]'),
      jsonEncode({'candidates': []}),
    ]) {
      final client = MockClient((_) async => http.Response(body, 200));
      await expectLater(
        run(extractor(client)),
        throwsA(
          isA<DomainException>().having(
            (e) => e.message,
            'message',
            contains('tidak bisa dibaca'),
          ),
        ),
        reason: body,
      );
    }
  });

  test('gagal koneksi: pesan internet', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    await expectLater(
      run(extractor(client)),
      throwsA(
        isA<DomainException>().having(
          (e) => e.message,
          'message',
          contains('internet'),
        ),
      ),
    );
  });
}
