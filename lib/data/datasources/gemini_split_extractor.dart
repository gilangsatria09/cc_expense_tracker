import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/error/domain_exception.dart';
import '../../domain/entities/extracted_split.dart';
import '../../domain/services/split_extractor.dart';

class GeminiSplitExtractor implements SplitExtractor {
  GeminiSplitExtractor({
    required http.Client client,
    required String? Function() apiKey,
    String? Function()? modelOverride,
    this.timeout = const Duration(seconds: 60),
  }) : _client = client,
       _apiKey = apiKey,
       _modelOverride = modelOverride;

  static const defaultModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.8-flash',
  ];

  static const _host = 'generativelanguage.googleapis.com';

  final http.Client _client;
  final String? Function() _apiKey;
  final String? Function()? _modelOverride;
  final Duration timeout;

  String? _workingModel;

  static const _prompt = '''
Kamu membaca foto struk atau screenshot chat grup order (makanan/belanja) di Indonesia.
Kembalikan daftar orang beserta total nominal (Rupiah, bilangan bulat tanpa titik/koma/simbol) yang harus dibayar masing-masing berdasarkan item yang dipesannya.
Aturan:
- Jumlahkan semua item milik orang yang sama.
- Jangan masukkan ongkir, biaya layanan, atau biaya pengiriman; itu dibagi terpisah.
- Pakai nama persis seperti tertulis di gambar.
- Kalau tidak ada nama pemesan yang jelas, kembalikan array kosong. Jangan mengarang.
''';

  static const _schema = {
    'type': 'ARRAY',
    'items': {
      'type': 'OBJECT',
      'properties': {
        'nama': {'type': 'STRING'},
        'subtotal': {'type': 'INTEGER'},
      },
      'required': ['nama', 'subtotal'],
    },
  };

  @override
  Future<List<ExtractedSplit>> extract({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final key = _apiKey();
    if (key == null || key.trim().isEmpty) {
      throw const DomainException(
        'API key Gemini belum diisi. Isi GEMINI_API_KEY di file .env',
      );
    }

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': _schema,
      },
    });

    final candidates = _candidates();
    for (final model in candidates) {
      final response = await _post(
        Uri.https(_host, '/v1beta/models/$model:generateContent'),
        key.trim(),
        body,
      );
      if (response.statusCode == 404) continue;

      final splits = _handle(response);
      _workingModel = model;
      return splits;
    }
    throw DomainException(await _modelNotAvailable(key.trim(), candidates));
  }

  List<String> _candidates() {
    final override = _modelOverride?.call()?.trim();
    return {
      ?_workingModel,
      if (override != null && override.isNotEmpty) override,
      ...defaultModels,
    }.toList();
  }

  Future<http.Response> _post(Uri uri, String key, String body) async {
    try {
      return await _client
          .post(
            uri,
            headers: {
              'content-type': 'application/json',
              'x-goog-api-key': key,
            },
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const DomainException('Gemini tidak merespons, coba lagi');
    } on http.ClientException {
      throw const DomainException(
        'Tidak bisa terhubung ke Gemini. Cek internet',
      );
    }
  }

  List<ExtractedSplit> _handle(http.Response response) {
    final code = response.statusCode;
    if (code == 429) {
      throw const DomainException('Kuota Gemini habis, coba lagi nanti');
    }
    if (code == 400 || code == 403) {
      throw DomainException(
        'Permintaan ke Gemini ditolak ($code)${_reason(response)}. Cek API key',
      );
    }
    if (code != 200) {
      throw DomainException('Gemini error ($code)${_reason(response)}');
    }
    return _parse(response.body);
  }

  String _reason(http.Response response) {
    try {
      final message =
          ((jsonDecode(response.body) as Map)['error'] as Map)['message'];
      if (message is String && message.trim().isNotEmpty) {
        final text = message.trim().replaceAll(RegExp(r'\s+'), ' ');
        return ': ${text.length > 200 ? '${text.substring(0, 200)}…' : text}';
      }
    } catch (_) {}
    return '';
  }

  Future<String> _modelNotAvailable(String key, List<String> tried) async {
    final base =
        'Model Gemini tidak tersedia untuk key ini (dicoba: ${tried.join(', ')})';
    try {
      final response = await _client
          .get(
            Uri.https(_host, '/v1beta/models', {'pageSize': '200'}),
            headers: {'x-goog-api-key': key},
          )
          .timeout(timeout);
      if (response.statusCode != 200) return '$base. Isi GEMINI_MODEL di .env';

      const skip = [
        'tts',
        'image',
        'live',
        'audio',
        'embedding',
        'aqa',
        'robotics',
      ];
      final available = <String>[
        for (final m in (jsonDecode(response.body) as Map)['models'] as List)
          if ((m['supportedGenerationMethods'] as List?)?.contains(
                    'generateContent',
                  ) ==
                  true &&
              (m['name'] as String).contains('gemini') &&
              !skip.any((s) => (m['name'] as String).contains(s)))
            (m['name'] as String).replaceFirst('models/', ''),
      ];
      if (available.isEmpty) return '$base. Isi GEMINI_MODEL di .env';
      return '$base. Model yang tersedia: ${available.take(6).join(', ')}. '
          'Isi GEMINI_MODEL di .env dengan salah satunya';
    } catch (_) {
      return '$base. Isi GEMINI_MODEL di .env';
    }
  }

  List<ExtractedSplit> _parse(String responseBody) {
    const unreadable = DomainException('Hasil ekstraksi tidak bisa dibaca');
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final text =
          (((json['candidates'] as List).first
                      as Map<String, dynamic>)['content']['parts']
                  as List)
              .map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
              .join();
      final items = jsonDecode(text) as List;

      final result = <ExtractedSplit>[];
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final nama = (map['nama'] as String).trim();
        final subtotal = (map['subtotal'] as num).round();
        if (nama.isEmpty || subtotal < 0) continue;
        result.add(ExtractedSplit(nama: nama, subtotal: subtotal));
      }
      return result;
    } on DomainException {
      rethrow;
    } catch (_) {
      throw unreadable;
    }
  }
}
