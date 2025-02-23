import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:scientry/screens/login.dart';
import 'package:scientry/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    splashScreen();
    setTheme();
  }

  void splashScreen() {
    FlutterNativeSplash.remove();
  }

  void setTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('darkTheme') ?? false;
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (isDark) {
      themeProvider.themeData = ThemeData.dark();
    } else {
      themeProvider.themeData = ThemeData.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Animate(
          onComplete: (controller) async {
            await Future.delayed(Duration(milliseconds: 800));
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Login();
                },
              ),
            );
          },
          autoPlay: true,
          effects: [
            ScaleEffect(
              delay: Duration(milliseconds: 800),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
            ),
            FadeEffect(
              delay: Duration(milliseconds: 800),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
            ),
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/splash_screen/brandlogo.png",
                width: 0.5 * screenWidth,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Scientry",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 5,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.onPrimary,
                thickness: 2,
                indent: 0.3 * screenWidth,
                endIndent: 0.3 * screenWidth,
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Text(
                    "Science Simplified,",
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "Knowledge Amplified",
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
