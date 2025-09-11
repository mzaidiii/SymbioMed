import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:symbiomed/Screens/newUser.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController abha = TextEditingController();

  bool validateAbha(String input) {
    final cleaned = input.replaceAll("-", "");
    final regex = RegExp(r'^[0-9]{14}$');
    return regex.hasMatch(cleaned);
  }

  Future<void> searchAbha(String abhaNo) async {
    final db = FirebaseFirestore.instance.collection('users').doc(abhaNo);
    final Snapshot = await db.get();

    if (Snapshot.exists) {
      print('Exits');
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => Newuser()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('android/assets/logo.png', height: 150),
                const SizedBox(height: 15),
                TextField(
                  controller: abha,
                  decoration: InputDecoration(
                    label: Text(
                      'Enter the ABHA ID',
                      style: GoogleFonts.robotoSlab(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    String Abha = abha.text.trim();
                    if (!validateAbha(Abha)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Enter a valid ABHA No.')),
                      );
                    }
                    await searchAbha(abha.text.trim());
                  },
                  child: Text('Search', style: GoogleFonts.robotoSlab()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
