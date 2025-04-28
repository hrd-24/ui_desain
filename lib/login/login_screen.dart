import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_desain/helper/db_helper.dart';
import 'package:ui_desain/home/home_screen.dart';
import 'package:ui_desain/regist/regist_screen.dart';
import 'package:ui_desain/reusable/function.dart'; // Import RegistScreen jika user tidak punya akun

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Text(
                "Login to your account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email*",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email or phone number',
                  hintStyle: TextStyle(color: Colors.brown),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password*",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.brown),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB58328),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _login,
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistScreen()),
                      );
                    },
                    child: Text(
                      "Register here",
                      style: TextStyle(
                        color: Color.fromARGB(255, 7, 119, 211),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi login
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Please enter both email and password');
      return;
    }

    // Cari user berdasarkan email dan password
    final user = await dbHelper.getUserByEmailAndPassword(email, password);

  if (user != null) {
  // Simpan user id ke SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', user['id']);

  // Login berhasil, pindah ke HomeScreen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()), // Pastikan HomeScreen sudah ada
  );
}
 else {
      // Login gagal, tampilkan pesan error
      _showDialog('Invalid email or password');
    }
  }

  // Fungsi untuk menampilkan dialog
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
