import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_desain/helper/db_helper.dart';
import 'package:ui_desain/list/absensi_model.dart';
import 'package:ui_desain/list/absensi_service.dart';
import 'package:ui_desain/list/list_screen.dart';
import 'package:ui_desain/login/login_screen.dart';
import 'package:ui_desain/profile.dart';
import 'package:ui_desain/reusable/function.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = "Mengambil lokasi...";
  bool _loading = true;
  String namaPengguna = '';
  final dbHelper = DatabaseHelper();
  bool _isAbsenMasukPressed = false; // Variabel untuk mengontrol status tombol

  @override
  void initState() {
    super.initState();
    _loadNamaPengguna();
    _initLocation();
  }

  Future<void> _loadNamaPengguna() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id'); // Ambil ID user yang login

    if (userId != null) {
      final user = await dbHelper.getUserById(userId); // Ambil data user dari database

      setState(() {
        namaPengguna = user?['name'] ?? 'User';
      });
    } else {
      setState(() {
        namaPengguna = 'User';
      });
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _initLocation() async {
    await initializeDateFormatting('id_ID', null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentAddress = "Layanan lokasi tidak aktif.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _currentAddress = "Izin lokasi ditolak.");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
          _loading = false;
        });
      } else {
        setState(() => _currentAddress = "Alamat tidak ditemukan");
      }
    } catch (e) {
      setState(() => _currentAddress = "Gagal mengambil lokasi: $e");
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  // Fungsi untuk menangani aksi Absen Masuk
  void _handleAbsenMasuk() {
    dbHelper.simpanAbsen('Masuk');
    setState(() {
      _isAbsenMasukPressed = true; // Menandakan tombol Absen Masuk ditekan
    });
  }

  // Fungsi untuk menangani aksi Absen Pulang
  void _handleAbsenPulang() {
    dbHelper.simpanAbsen('Pulang');
    setState(() {
      _isAbsenMasukPressed = false; // Menandakan tombol Absen Pulang ditekan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text('Dashboard Absensi'),
        backgroundColor: appBarBG(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${namaPengguna.isEmpty ? "User" : namaPengguna}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    getFormattedDate(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Lokasi Saat Ini:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(_currentAddress),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isAbsenMasukPressed ? null : _handleAbsenMasuk,
                        child: Text("Absen Masuk"),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: !_isAbsenMasukPressed ? null : _handleAbsenPulang,
                        child: Text("Absen Pulang"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListAbsen()),
          );
        },
        backgroundColor: appBarBG(),
        child: Icon(Icons.list),
      ),
    );
  }
}

