import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<SavedQuote>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _quotesFuture = StorageService().readAllQuotes();
    });
  }

  Future<void> _delete(SavedQuote quote) async {
    await StorageService().deleteQuote(quote);
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Orçamentos')),
      body: FutureBuilder<List<SavedQuote>>(
        future: _quotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum orçamento salvo.'));
          }

          final quotes = snapshot.data!;
          final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Dismissible(
                key: Key(quote.id.toString()),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _delete(quote),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.blueGrey),
                    title: Text(quote.clientName.isEmpty ? 'Cliente Sem Nome' : quote.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${quote.date} - ${quote.result.moduleName}'),
                    trailing: Text(currency.format(quote.totalValue), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
