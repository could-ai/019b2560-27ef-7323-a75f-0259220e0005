import '../models/stock_snapshot.dart';

class MockScreenerService {
  Future<ScreenerResult> runScreen(String keyword) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final k = keyword.toLowerCase();

    if (k.contains('semi')) {
      return ScreenerResult(
        industryMatched: 'semiconductors',
        originalTickers: ['NVDA', 'AMD', 'INTC', 'AVGO', 'QCOM', 'TXN', 'MRVL', 'MU'],
        filteredStocks: [
          StockSnapshot(
            ticker: 'NVDA',
            currentPrice: 130.00, // Updated approx price
            marketCapB: 3000.0,
            revenueGrowth: 2.65,
            grossMargin: 0.76,
            trailingPE: 75.0,
            beta: 1.6,
          ),
          StockSnapshot(
            ticker: 'AMD',
            currentPrice: 170.00,
            marketCapB: 275.0,
            revenueGrowth: 0.18,
            grossMargin: 0.52,
            trailingPE: 320.0,
            beta: 1.7,
          ),
          StockSnapshot(
            ticker: 'AVGO',
            currentPrice: 1300.00,
            marketCapB: 600.0,
            revenueGrowth: 0.34,
            grossMargin: 0.65,
            trailingPE: 45.0,
            beta: 1.1,
          ),
          // Added previously "filtered" stocks for testing purposes
          StockSnapshot(
            ticker: 'INTC',
            currentPrice: 30.00,
            marketCapB: 130.0,
            revenueGrowth: -0.05,
            grossMargin: 0.40,
            trailingPE: 30.0,
            beta: 1.1,
          ),
          StockSnapshot(
            ticker: 'QCOM',
            currentPrice: 175.00,
            marketCapB: 195.0,
            revenueGrowth: 0.05,
            grossMargin: 0.56,
            trailingPE: 24.0,
            beta: 1.3,
          ),
          StockSnapshot(
            ticker: 'TXN',
            currentPrice: 170.00,
            marketCapB: 155.0,
            revenueGrowth: -0.10,
            grossMargin: 0.63,
            trailingPE: 28.0,
            beta: 1.0,
          ),
          StockSnapshot(
            ticker: 'MU',
            currentPrice: 120.00,
            marketCapB: 135.0,
            revenueGrowth: 0.50,
            grossMargin: 0.25,
            trailingPE: -20.0, // Negative PE example
            beta: 1.5,
          ),
        ],
      );
    } else if (k.contains('ai') || k.contains('soft')) {
      return ScreenerResult(
        industryMatched: 'ai_software',
        originalTickers: ['MSFT', 'GOOGL', 'META', 'ADBE', 'CRM'],
        filteredStocks: [
          StockSnapshot(
            ticker: 'MSFT',
            currentPrice: 415.00,
            marketCapB: 3090.0,
            revenueGrowth: 0.17,
            grossMargin: 0.68,
            trailingPE: 36.0,
            beta: 0.9,
          ),
          StockSnapshot(
            ticker: 'META',
            currentPrice: 485.00,
            marketCapB: 1200.0,
            revenueGrowth: 0.25,
            grossMargin: 0.80,
            trailingPE: 32.0,
            beta: 1.2,
          ),
          // Added previously "filtered" stocks for testing purposes
          StockSnapshot(
            ticker: 'GOOGL',
            currentPrice: 175.00,
            marketCapB: 2100.0,
            revenueGrowth: 0.15,
            grossMargin: 0.57,
            trailingPE: 26.0,
            beta: 1.05,
          ),
          StockSnapshot(
            ticker: 'ADBE',
            currentPrice: 480.00,
            marketCapB: 220.0,
            revenueGrowth: 0.11,
            grossMargin: 0.88,
            trailingPE: 45.0,
            beta: 1.3,
          ),
          StockSnapshot(
            ticker: 'CRM',
            currentPrice: 300.00,
            marketCapB: 290.0,
            revenueGrowth: 0.11,
            grossMargin: 0.75,
            trailingPE: 60.0,
            beta: 1.2,
          ),
        ],
      );
    } else {
      throw Exception('Industry "$keyword" not found in mock database. Try "semi" or "ai".');
    }
  }
}
