import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/onboarding/welcome.dart';
import 'package:scientry/screens/homepage.dart';
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

  void splashScreen() async {
    FlutterNativeSplash.remove();
  }

  bool _isFirstTime() {
    final prefs = Provider.of<SharedPreferences>(context, listen: false);
    return prefs.getBool('firstTime') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('app_started');
    var screenWidth = MediaQuery.of(context).size.width;
    bool isFirstTime = _isFirstTime();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Animate(
          onComplete: (controller) async {
            await Future.delayed(Duration(milliseconds: 800));
            if (isFirstTime) {
              context.pushReplacementTransition(
                type: PageTransitionType.leftToRightWithFade,
                child: Welcome(),
              );
            } else {
              context.pushReplacementTransition(
                type: PageTransitionType.leftToRightWithFade,
                child: HomePage(),
              );
            }
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
