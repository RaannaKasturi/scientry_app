import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:scientry/screens/homepage.dart';

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
  }

  void splashScreen() async {
    await Future.delayed(const Duration(milliseconds: 700));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/splashscreen.json',
                width: 0.25 * screenWidth,
                fit: BoxFit.cover,
                repeat: false,
                animate: true,
                alignment: Alignment.center,
                renderCache: RenderCache.raster,
                filterQuality: FilterQuality.high,
                options: LottieOptions(enableMergePaths: true),
                frameRate: FrameRate(120)),
            Animate(
              onComplete: (controller) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePage();
                    },
                  ),
                );
              },
              autoPlay: true,
              effects: [
                ScaleEffect(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                ),
                FadeEffect(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                ),
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
