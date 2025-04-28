import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_desain/helper/db_helper.dart';
import 'package:ui_desain/reusable/function.dart';

class ListAbsen extends StatelessWidget {
  const ListAbsen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Absensi'),
        backgroundColor: appBarBG(),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getAllAbsen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data absensi.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final absen = snapshot.data![index];

              String waktuMasuk = absen['waktu_masuk'] ?? "-";
              String waktuPulang = absen['waktu_pulang'] ?? "-";
              String lokasiMasuk = absen['lokasi_masuk'] ?? "-";
              String lokasiPulang = absen['lokasi_pulang'] ?? "-";

              // Optional: Format Jam
              String jamMasuk = "-";
              String jamPulang = "-";

              if (waktuMasuk != "-") {
                jamMasuk = DateFormat(
                  'HH:mm',
                ).format(DateTime.parse(waktuMasuk));
              }
              if (waktuPulang != "-") {
                jamPulang = DateFormat(
                  'HH:mm',
                ).format(DateTime.parse(waktuPulang));
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tanggal: ${absen['waktu_masuk'] != null ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(absen['waktu_masuk'])) : "-"}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Absen Masuk",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Waktu: ${absen['waktu_masuk'] != null ? DateFormat('HH:mm').format(DateTime.parse(absen['waktu_masuk'])) : "-"}",
                      ),
                      Text("Lokasi: ${absen['lokasi_masuk'] ?? '-'}"),
                      SizedBox(height: 12),
                      Text(
                        "Absen Pulang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Waktu: ${absen['waktu_pulang'] != null ? DateFormat('HH:mm').format(DateTime.parse(absen['waktu_pulang'])) : "-"}",
                      ),
                      Text("Lokasi: ${absen['lokasi_pulang'] ?? '-'}"),
                    ],
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
