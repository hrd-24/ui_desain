// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'absensi_model.dart';

// class AbsensiService {
//   static const String key = 'data_absensi';

//   static Future<void> tambahAbsensi(Absensi absensi) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> listString = prefs.getStringList(key) ?? [];

//     listString.add(jsonEncode(absensi.toJson()));
//     await prefs.setStringList(key, listString);
//   }

//   static Future<List<Absensi>> getDaftarAbsensi() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> listString = prefs.getStringList(key) ?? [];

//     return listString
//         .map((item) => Absensi.fromJson(jsonDecode(item)))
//         .toList();
//   }
// }
