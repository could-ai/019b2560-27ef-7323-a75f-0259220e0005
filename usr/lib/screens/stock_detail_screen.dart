import 'package:flutter/material.dart';
import '../models/stock_snapshot.dart';

class StockDetailScreen extends StatelessWidget {
  final StockSnapshot stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${stock.ticker} Analysis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stock.ticker,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NasdaqGS', // Placeholder exchange
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  '\$${stock.currentPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Snapshot Data Grid
            Text('Snapshot Metrics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricColumn(context, 'Market Cap', '\$${stock.marketCapB}B'),
                        _buildMetricColumn(context, 'Rev Growth', '${(stock.revenueGrowth * 100).toStringAsFixed(1)}%', 
                          color: stock.revenueGrowth > 0.15 ? Colors.green : null),
                        _buildMetricColumn(context, 'Gross Margin', '${(stock.grossMargin * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricColumn(context, 'Trailing PE', stock.trailingPE?.toStringAsFixed(1) ?? 'N/A'),
                        _buildMetricColumn(context, 'Beta', stock.beta?.toStringAsFixed(2) ?? 'N/A'),
                        _buildMetricColumn(context, 'PEG Ratio', '1.2'), // Placeholder
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Deep Analysis Placeholder (Simulating the Python backend flow)
            Row(
              children: [
                const Icon(Icons.science, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Deep Analysis Pipeline', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisStep(context, '1. Data Fetcher', 'Completed', Icons.check_circle, Colors.green),
            _buildAnalysisStep(context, '2. Valuation Engine', 'Processing DCF Model...', Icons.sync, Colors.orange),
            _buildAnalysisStep(context, '3. Scoring Engine', 'Pending', Icons.circle_outlined, Colors.grey),
            _buildAnalysisStep(context, '4. Report Generation', 'Pending', Icons.circle_outlined, Colors.grey),
            
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full report generation started...')),
                  );
                },
                icon: const Icon(Icons.assessment),
                label: const Text('Generate Full Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value, 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisStep(BuildContext context, String title, String status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(status, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
