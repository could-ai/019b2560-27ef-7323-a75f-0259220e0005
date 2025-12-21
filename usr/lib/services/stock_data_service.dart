import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the Company Overview (Fundamental Data)
  Future<Map<String, dynamic>> getCompanyOverview(String symbol) async {
    try {
      final response = await _supabase.functions.invoke(
        'alpha-vantage-proxy',
        body: {'symbol': symbol, 'endpoint': 'overview'},
      );

      final data = response.data;
      
      // Check for Rate Limit or API Note
      if (data is Map<String, dynamic>) {
        if (data.containsKey('Note')) {
          print('Alpha Vantage Rate Limit: ${data['Note']}');
          throw Exception('API Rate Limit Exceeded (5 calls/min)');
        }
        if (data.containsKey('Information')) {
           print('Alpha Vantage Info: ${data['Information']}');
           throw Exception('API Limit: ${data['Information']}');
        }
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return data;
      }
      return {};
    } catch (e) {
      print('Error fetching overview: $e');
      rethrow;
    }
  }

  /// Fetches the Global Quote (Price Data)
  Future<Map<String, dynamic>> getGlobalQuote(String symbol) async {
    try {
      final response = await _supabase.functions.invoke(
        'alpha-vantage-proxy',
        body: {'symbol': symbol, 'endpoint': 'quote'},
      );

      final data = response.data;
      
      if (data is Map<String, dynamic>) {
         if (data.containsKey('Note')) {
          print('Alpha Vantage Rate Limit: ${data['Note']}');
          throw Exception('API Rate Limit Exceeded (5 calls/min)');
        }
        if (data.containsKey('Global Quote')) {
          return data['Global Quote'];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching quote: $e');
      // Don't rethrow here to allow partial data loading, just return empty
      return {}; 
    }
  }
}
