import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scientry/screens/auth/register.dart';
import 'package:scientry/screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientry',
      theme: ThemeData(
        fontFamily: GoogleFonts.getFont("Syne").fontFamily,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(28, 35, 99, 100)),
        useMaterial3: true,
      ),
      home: Register(),
    );
  }
}
