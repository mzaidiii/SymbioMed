import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:symbiomed/Screens/HomePage.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.message ?? 'Login failed';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 10),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          '😊Welcom Back..!',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: email,
                          decoration: InputDecoration(label: Text('Enter Id')),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          obscureText: true,
                          controller: password,
                          decoration: InputDecoration(
                            label: Text('Enter Password'),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: login,
                          child: Text(
                            'Sign In to potral',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            if (email.text.trim().isNotEmpty) {
                              await resetPassword(email.text.trim());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Enter the Email First'),
                                ),
                              );
                            }
                          },
                          child: Text('Forgotten password'),
                        ),
                      ],
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
}
