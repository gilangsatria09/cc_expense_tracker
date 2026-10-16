import 'package:cc_expense_tracker/domain/usecases/split_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ongkirShares: sisa pembulatan ke orang pertama, jumlah tepat', () {
    expect(SplitCalculator.ongkirShares(10000, 3), [3334, 3333, 3333]);
    expect(SplitCalculator.ongkirShares(10000, 4), [2500, 2500, 2500, 2500]);
    expect(SplitCalculator.ongkirShares(2, 3), [1, 1, 0]);
    expect(SplitCalculator.ongkirShares(5000, 0), isEmpty);
  });

  test('foldOngkir menambah porsi ongkir ke tiap subtotal', () {
    final folded = SplitCalculator.foldOngkir([20000, 30000, 40000], 10000);
    expect(folded, [23334, 33333, 43333]);
    expect(folded.reduce((a, b) => a + b), 100000);
  });

  test('selisih: positif kalau kurang, negatif kalau lebih', () {
    expect(
      SplitCalculator.selisih(totalTagihan: 100000, amounts: [40000, 50000]),
      10000,
    );
    expect(
      SplitCalculator.selisih(totalTagihan: 100000, amounts: [60000, 50000]),
      -10000,
    );
    expect(
      SplitCalculator.selisih(totalTagihan: 100000, amounts: [50000, 50000]),
      0,
    );
  });
}
