import 'package:flutter/material.dart';
import '../models/stock_snapshot.dart';
import '../services/stock_data_service.dart';

class StockDetailScreen extends StatefulWidget {
  final StockSnapshot stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final StockDataService _dataService = StockDataService();
  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _quoteData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    try {
      // Fetch Company Overview and Quote from Alpha Vantage via Edge Function
      final overviewFuture = _dataService.getCompanyOverview(widget.stock.ticker);
      final quoteFuture = _dataService.getGlobalQuote(widget.stock.ticker);

      final results = await Future.wait([overviewFuture, quoteFuture]);
      
      if (mounted) {
        setState(() {
          _overviewData = results[0];
          _quoteData = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use real price if available, otherwise fallback to snapshot
    final displayPrice = _quoteData != null && _quoteData!['05. price'] != null
        ? double.tryParse(_quoteData!['05. price']) ?? widget.stock.currentPrice
        : widget.stock.currentPrice;

    final displayChangePercent = _quoteData != null && _quoteData!['10. change percent'] != null
        ? _quoteData!['10. change percent']
        : '0.00%';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stock.ticker} Analysis'),
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
                        widget.stock.ticker,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _overviewData?['Exchange'] ?? 'NasdaqGS', 
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${displayPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      displayChangePercent,
                      style: TextStyle(
                        color: (displayChangePercent.toString().contains('-')) ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Real Data / Description Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Could not fetch live details: $_error')),
                  ],
                ),
              )
            else if (_overviewData != null && _overviewData!.isNotEmpty)
               _buildOverviewCard(context, _overviewData!),

            const SizedBox(height: 24),

            // Snapshot Data Grid (From Screener)
            Text('Key Metrics', style: Theme.of(context).textTheme.titleLarge),
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
                        _buildMetricColumn(context, 'Market Cap', _overviewData?['MarketCapitalization'] != null 
                            ? '\$${(double.parse(_overviewData!['MarketCapitalization']) / 1000000000).toStringAsFixed(1)}B' 
                            : '\$${widget.stock.marketCapB}B'),
                        _buildMetricColumn(context, 'Rev Growth', _overviewData?['QuarterlyRevenueGrowthYOY'] != null
                            ? '${(double.parse(_overviewData!['QuarterlyRevenueGrowthYOY']) * 100).toStringAsFixed(1)}%'
                            : '${(widget.stock.revenueGrowth * 100).toStringAsFixed(1)}%', 
                          color: Colors.green),
                        _buildMetricColumn(context, 'Gross Margin', _overviewData?['GrossProfitTTM'] != null && _overviewData?['RevenueTTM'] != null
                            ? '${((double.parse(_overviewData!['GrossProfitTTM']) / double.parse(_overviewData!['RevenueTTM'])) * 100).toStringAsFixed(1)}%'
                            : '${(widget.stock.grossMargin * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricColumn(context, 'Trailing PE', _overviewData?['PERatio'] ?? widget.stock.trailingPE?.toStringAsFixed(1) ?? 'N/A'),
                        _buildMetricColumn(context, 'Beta', _overviewData?['Beta'] ?? widget.stock.beta?.toStringAsFixed(2) ?? 'N/A'),
                        _buildMetricColumn(context, 'PEG Ratio', _overviewData?['PEG'] ?? 'N/A'), 
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Deep Analysis Pipeline
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

  Widget _buildOverviewCard(BuildContext context, Map<String, dynamic> data) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              data['Description'] ?? 'No description available.',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoBadge(label: 'Sector', value: data['Sector'] ?? 'N/A'),
                _InfoBadge(label: 'Industry', value: data['Industry'] ?? 'N/A'),
                _InfoBadge(label: '52W High', value: data['52WeekHigh'] ?? 'N/A'),
                _InfoBadge(label: '52W Low', value: data['52WeekLow'] ?? 'N/A'),
              ],
            )
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

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
