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
      final user = await dbHelper.getUserById(
        userId,
      ); // Ambil data user dari database

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
      leading: IconButton(
        icon: const Icon(Icons.logout),
        onPressed: logout,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            _loadNamaPengguna();
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            namaPengguna.isEmpty ? "User" : namaPengguna,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            getFormattedDate(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.blue[50],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Lokasi Saat Ini",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _currentAddress,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAbsenMasukPressed ? null : _handleAbsenMasuk,
                          icon: Icon(Icons.login),
                          label: Text("Absen Masuk"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !_isAbsenMasukPressed ? null : _handleAbsenPulang,
                          icon: Icon(Icons.logout),
                          label: Text("Absen Pulang"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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