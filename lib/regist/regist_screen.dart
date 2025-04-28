import 'package:flutter/material.dart';
import 'package:ui_desain/helper/db_helper.dart';
import 'package:ui_desain/login/login_screen.dart';
import 'package:ui_desain/reusable/function.dart';
import 'dart:core'; // Untuk regex validasi

class RegistScreen extends StatefulWidget {
  @override
  State<RegistScreen> createState() => _RegistScreenState();
}

class _RegistScreenState extends State<RegistScreen> {
  bool _obscureText = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final dbHelper = DatabaseHelper();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9!@#\$&*~]).{6,}$');
    return passwordRegex.hasMatch(password);
  }

void _register() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    _showDialog('Please fill all fields');
    return;
  }

  if (!_validateEmail(email)) {
    _showDialog('Invalid email format');
    return;
  }

  if (!_validatePassword(password)) {
    _showDialog('Password must contain at least one capital letter and a number or symbol');
    return;
  }

  final user = {
    'name': name,
    'email': email,
    'password': password,
  };

  await dbHelper.insertUser(user);

  _showDialog('Account created successfully!');

  _nameController.clear();
  _emailController.clear();
  _passwordController.clear();

  // Tambahkan delay sebentar agar user sempat lihat dialog sukses
  Future.delayed(Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  });
}


  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Info'),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                SizedBox(height: 40),
                Text(
                  "Register to create account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                buildInputLabel("Name*"),
                buildTextField(_nameController, "Your name"),
                SizedBox(height: 16),
                buildInputLabel("Email*"),
                buildTextField(_emailController, "Email"),
                SizedBox(height: 16),
                buildInputLabel("Password*"),
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
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 24),
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
                    onPressed: _register,
                    child: Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.brown),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white70,
      ),
    );
  }
}
