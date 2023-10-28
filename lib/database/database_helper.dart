import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Database info
  static final _databaseName = "reservation_database.db";
  static final _databaseVersion = 1;

  // Table name
  static final table = 'reservations';

  // Column names
  static final columnId = 'id';
  static final columnDate = 'date';
  static final columnTime = 'time';

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDate TEXT NOT NULL,
            $columnTime TEXT NOT NULL
          )
          ''');
  }

  // CRUD Functions

  // Insert
  Future<int> insertReservation(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Read all
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Read specific
  Future<Map<String, dynamic>?> queryReservation(int id) async {
    Database db = await instance.database;
    var res = await db.query(table, where: '$columnId = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // Update
  Future<int> updateReservation(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete
  Future<int> deleteReservation(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
