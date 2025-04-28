  // Fungsi untuk menampilkan Toast
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// void showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: const Color.fromARGB(255, 3, 110, 182),
//       textColor: const Color.fromARGB(255, 245, 242, 242),
//       fontSize: 14.0,
//     );
//   }


Color appBarBG() {
  return const Color.fromARGB(255, 32, 160, 210);
}
Color textWhite() {
  return const Color.fromARGB(255, 255, 255, 255);
}

Color textBlack() {
  return const Color.fromARGB(255, 0, 0, 0);
}

Color backgroundColor() {
  return const Color.fromARGB(255, 208, 182, 166);
}

Color brown() {
  return const Color.fromARGB(255, 176, 79, 18);
}
Color bg_cream() {
  return const Color.fromARGB(255, 218, 130, 75);
}

class Hrd_Productss extends StatelessWidget {
  final double height;

  const Hrd_Productss({Key? key, this.height = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/hrd_productss.png',
      height: height,
    );
  }
}

class NewUser {
 static const String hrdpage = 'HrdPage';
}
class PathStorage {
 static const String hrdstorage = 'HrdStorage/';
}  
