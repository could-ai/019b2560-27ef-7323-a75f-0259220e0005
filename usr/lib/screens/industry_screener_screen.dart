import 'package:flutter/material.dart';
import '../services/mock_screener_service.dart';
import '../models/stock_snapshot.dart';
import 'stock_detail_screen.dart';

class IndustryScreenerScreen extends StatefulWidget {
  const IndustryScreenerScreen({super.key});

  @override
  State<IndustryScreenerScreen> createState() => _IndustryScreenerScreenState();
}

class _IndustryScreenerScreenState extends State<IndustryScreenerScreen> {
  final TextEditingController _controller = TextEditingController();
  final MockScreenerService _screenerService = MockScreenerService();
  
  bool _isLoading = false;
  ScreenerResult? _result;
  String? _error;

  void _runScreen() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      // Simulate network delay and processing
      final result = await _screenerService.runScreen(keyword);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Screener'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Industry Keyword',
                        hintText: 'e.g., semiconductor, ai, cloud',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _runScreen(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _runScreen,
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.filter_list),
                      label: Text(_isLoading ? 'Screening...' : 'Run Screen'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Results Section
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (_result == null && !_isLoading) {
      return const Center(
        child: Text(
          'Enter an industry keyword to start screening.\nTry "semi" or "ai".',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_result != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found ${_result!.filteredStocks.length} potential stocks in "${_result!.industryMatched}"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _result!.filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = _result!.filteredStocks[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: Text(stock.ticker.substring(0, 1)),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(stock.ticker, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${stock.currentPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _InfoBadge(label: 'Cap', value: '${stock.marketCapB.toStringAsFixed(1)}B'),
                            const SizedBox(width: 8),
                            _InfoBadge(label: 'PE', value: stock.trailingPE?.toStringAsFixed(1) ?? 'N/A'),
                            const SizedBox(width: 8),
                            _InfoBadge(
                              label: 'Growth', 
                              value: '${(stock.revenueGrowth * 100).toStringAsFixed(1)}%',
                              color: stock.revenueGrowth > 0.15 ? Colors.green.shade100 : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailScreen(stock: stock),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoBadge({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
