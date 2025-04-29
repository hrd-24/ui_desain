import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'absen.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE absensi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        waktu_masuk TEXT,
        lokasi_masuk TEXT,
        waktu_pulang TEXT,
        lokasi_pulang TEXT
      )
    ''');
  }

Future<Map<String, dynamic>?> getUserById(int id) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}


  // --- User Functions ---
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // --- Absensi Functions ---
  Future<int> addAbsenMasuk(String waktuMasuk, String lokasiMasuk) async {
    final db = await database;
    return await db.insert('absensi', {
      'waktu_masuk': waktuMasuk,
      'lokasi_masuk': lokasiMasuk,
      'waktu_pulang': null,
      'lokasi_pulang': null,
    });
  }

  Future<int> updateAbsenPulang(int id, String waktuPulang, String lokasiPulang) async {
    final db = await database;
    return await db.update(
      'absensi',
      {
        'waktu_pulang': waktuPulang,
        'lokasi_pulang': lokasiPulang,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUserName(int userId, String newName) async {
  final db = await database;
  await db.update(
    'users', // ganti sesuai nama tabel kamu
    {'name': newName},
    where: 'id = ?',
    whereArgs: [userId],
  );
}


  Future<Map<String, dynamic>?> getLastAbsenWithoutPulang() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'absensi',
      where: 'waktu_pulang IS NULL',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllAbsen() async {
    final db = await database;
    return await db.query('absensi', orderBy: 'id DESC');
  }

Future<List<Map<String, dynamic>>> getAbsen() async {
  final db = await database;
  return await db.query(
    'absensi',
    orderBy: 'waktu_masuk DESC', // <-- ini biar data terbaru di atas
  );
}



Future<void> simpanAbsen(String tipe) async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  String waktuSekarang = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  // Ubah koordinat jadi alamat
  List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  String alamat = "Lokasi tidak ditemukan";
  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    alamat = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  }

  final db = await database;

  if (tipe == 'Masuk') {
    // INSERT data baru
    await db.insert('absensi', {
      'waktu_masuk': waktuSekarang,
      'lokasi_masuk': alamat,
      'waktu_pulang': null,
      'lokasi_pulang': null,
    });
  } else if (tipe == 'Pulang') {
    // Cari record terakhir yang waktu_pulang nya masih null
    List<Map<String, dynamic>> result = await db.query(
      'absensi',
      where: 'waktu_pulang IS NULL',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      int id = result.first['id'];

      // UPDATE record itu
      await db.update(
        'absensi',
        {
          'waktu_pulang': waktuSekarang,
          'lokasi_pulang': alamat,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}

}
