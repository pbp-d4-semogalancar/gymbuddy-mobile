import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymbuddy/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(
                text: 'Gym',
                style: TextStyle(color: Colors.grey),
              ),
              TextSpan(
                text: 'Buddy',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Username Field
                  TextField(
                    controller: _usernameController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12.0),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),

                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String password = _passwordController.text;
                      String confirmPassword = _confirmPasswordController.text;

                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match!'),
                          ),
                        );
                        return;
                      }

                      // [PERBAIKAN PENTING]
                      // Gunakan '/auth/api/register/'
                      // Perhatikan parameter di backend Anda: 'password1' dan 'password2'
                      // Backend Anda membaca json.loads(request.body) di register_user_api
                      final response = await request.postJson(
                        "http://127.0.0.1:8000/auth/api/register/",
                        jsonEncode(<String, String>{
                          'username': username,
                          'password1':
                              password, // Sesuaikan key dengan backend (password1)
                          'password2':
                              confirmPassword, // Sesuaikan key dengan backend (password2)
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully registered!'),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ?? 'Failed to register!',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
