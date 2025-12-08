import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gessocrm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE quotes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_name TEXT NOT NULL,
  total_value REAL NOT NULL,
  date TEXT NOT NULL,
  json_data TEXT NOT NULL
)
''');
  }

  Future<int> createQuote(SavedQuote quote) async {
    final db = await instance.database;
    final map = quote.toMap();
    // Serialize the complex object to JSON string
    map['json_data'] = jsonEncode(quote.result.toJson());
    return await db.insert('quotes', map);
  }

  Future<List<SavedQuote>> readAllQuotes() async {
    final db = await instance.database;
    final result = await db.query('quotes', orderBy: 'date DESC');

    return result.map((json) {
      return SavedQuote(
        id: json['id'] as int,
        clientName: json['client_name'] as String,
        totalValue: json['total_value'] as double,
        date: json['date'] as String,
        result: CalculationResult.fromJson(jsonDecode(json['json_data'] as String)),
      );
    }).toList();
  }
  
  Future<int> deleteQuote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
