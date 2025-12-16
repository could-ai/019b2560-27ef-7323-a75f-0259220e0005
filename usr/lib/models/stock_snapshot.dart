class StockSnapshot {
  final String ticker;
  final double currentPrice;
  final double marketCapB;
  final double revenueGrowth;
  final double grossMargin;
  final double? trailingPE;
  final double? beta;

  StockSnapshot({
    required this.ticker,
    required this.currentPrice,
    required this.marketCapB,
    required this.revenueGrowth,
    required this.grossMargin,
    this.trailingPE,
    this.beta,
  });
}

class ScreenerResult {
  final String industryMatched;
  final List<String> originalTickers;
  final List<StockSnapshot> filteredStocks;

  ScreenerResult({
    required this.industryMatched,
    required this.originalTickers,
    required this.filteredStocks,
  });
}
