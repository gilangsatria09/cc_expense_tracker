class SplitCalculator {
  const SplitCalculator._();

  static List<int> ongkirShares(int ongkir, int count) {
    if (count <= 0) return const [];
    final base = ongkir ~/ count;
    final remainder = ongkir % count;
    return [for (var i = 0; i < count; i++) base + (i < remainder ? 1 : 0)];
  }

  static List<int> foldOngkir(List<int> subtotals, int ongkir) {
    final shares = ongkirShares(ongkir, subtotals.length);
    return [
      for (var i = 0; i < subtotals.length; i++) subtotals[i] + shares[i],
    ];
  }

  static int selisih({required int totalTagihan, required List<int> amounts}) =>
      totalTagihan - amounts.fold(0, (a, b) => a + b);
}
