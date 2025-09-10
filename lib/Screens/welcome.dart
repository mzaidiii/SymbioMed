import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:symbiomed/Screens/Login.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              child: LottieBuilder.asset('android/assets/welcom.json'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Welcome To SymbioMed',
            style: GoogleFonts.robotoSlab(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => Login()),
              );
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
