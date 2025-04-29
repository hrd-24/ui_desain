import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_desain/helper/db_helper.dart';
import 'package:ui_desain/reusable/function.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Nama Pengguna";
  String email = "email@example.com";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(
      'user_id',
    ); // asumsi kamu simpan user id saat login

    if (userId != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      Map<String, dynamic>? user = await dbHelper.getUserById(userId);

      if (user != null) {
        setState(() {
          name = user['name'] ?? "Nama Pengguna";
          email = user['email'] ?? "email@example.com";
        });
      }
    }
  }

  void showEditNameDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Nama'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Baru'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  int? userId = prefs.getInt('user_id');
                  if (userId != null) {
                    DatabaseHelper dbHelper = DatabaseHelper();
                    await dbHelper.updateUserName(
                      userId,
                      newName,
                    ); // fungsi update ke database
                    setState(() {
                      name = newName;
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), backgroundColor: appBarBG()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showEditNameDialog(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const Divider(height: 30, thickness: 1.2),
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: const Text("Nama Lengkap"),
                    subtitle: Text(name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text("Email"),
                    subtitle: Text(email),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
