import 'package:breath_state/constants/db_constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, DB_NAME);

    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('Create table $BREATH_TABLE_NAME (date TEXT, rate INTEGER)');
        await db.execute('Create table $HEART_TABLE_NAME (date TEXT, rate INTEGER)');
      },
    );

    return database;
  }

  Future<void> addData(int rate, String tableName) async {
    Database db = await database;
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    int status = await db.insert(tableName, {
      "date": formattedDateTime,
      "rate": rate,
    });
    if (status == 0) {
      developer.log("Error inserting");
      throw Error();
    }
  }

  Future<List<Map>> getData(String tableName) async {
    
    Database db = await database;
    List<Map> rows = await db.query(tableName);

    return rows;
  }

  //TODO Add for heart rate (abstract)
}
