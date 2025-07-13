import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  final String _table_name = "breathe_rate";

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "health.db");

    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('Create table $_table_name (date TEXT, rate INTEGER)');
      },
    );

    return database;
  }

  //TODO Add collum, table, db names in constants
  Future<void> addData(int rate) async {
    Database db = await database;
    final now = DateTime.now();
  final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    int status = await db.insert(_table_name, {
      "date": formattedDateTime,
      "rate": rate,
    });
    if (status == 0) {
      developer.log("Error inserting");
      throw Error();
    }
  }

  Future<List<Map>> getData() async {
    
    Database db = await database;
    List<Map> rows = await db.query(_table_name);

    return rows;
  }

  //TODO Add for heart rate (abstract)
}
