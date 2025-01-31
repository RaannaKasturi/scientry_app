import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scientry/screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          buttonTheme: ButtonThemeData(
            buttonColor: Theme.of(context).colorScheme.primary,
            textTheme: ButtonTextTheme.primary,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(28, 35, 99, 100)),
          useMaterial3: true,
        ),
        home: HomePage());
  }
}
