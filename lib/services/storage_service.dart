import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _keyQuotes = 'saved_quotes';

  Future<void> saveQuote(SavedQuote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> quotesJson = prefs.getStringList(_keyQuotes) ?? [];
    
    // Add new quote
    quotesJson.add(jsonEncode(quote.toMap()));
    
    await prefs.setStringList(_keyQuotes, quotesJson);
  }

  Future<List<SavedQuote>> readAllQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> quotesJson = prefs.getStringList(_keyQuotes) ?? [];

    return quotesJson.map((q) {
        final map = jsonDecode(q);
        // Handle the nested json_data we created earlier or simplify
        // Adapting to simple map format
        return SavedQuote(
          id: map['id'], // Can be null/random
          clientName: map['client_name'],
          totalValue: map['total_value'],
          date: map['date'],
          result: CalculationResult.fromJson(jsonDecode(map['json_data'])),
        );
    }).toList();
  }
  
  Future<void> deleteQuote(SavedQuote quoteToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> quotesJson = prefs.getStringList(_keyQuotes) ?? [];
    
    // Filter out the quote (comparing date/client as ID might be fuzzy)
    quotesJson.removeWhere((q) {
        final map = jsonDecode(q);
        return map['date'] == quoteToDelete.date && map['client_name'] == quoteToDelete.clientName;
    });
    
    await prefs.setStringList(_keyQuotes, quotesJson);
  }
}
