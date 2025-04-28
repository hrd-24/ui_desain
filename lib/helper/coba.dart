// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';


// class DatabaseHelper {
//   static Database? _database;

//   Future<Database> get database async {
//     _database ??= await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     String path = join(await getDatabasesPath(), 'absen.db');
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE absensi(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         tipe TEXT,
//         waktu TEXT,
//         latitude REAL,
//         longitude REAL
//       )
//     ''');
//   }

//   Future<void> addAbsen(Map<String, dynamic> absen) async {
//     final db = await database;
//     await db.insert('absensi', absen);
//   }

//   Future<List<Map<String, dynamic>>> getAbsen() async {
//     final db = await database;
//     return await db.query('absensi');
//   }
// }
