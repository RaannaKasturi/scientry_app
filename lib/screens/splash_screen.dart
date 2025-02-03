import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/homepage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Animate(
          delay: Duration(milliseconds: 500),
          effects: [
            ScaleEffect(
              alignment: Alignment.center,
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              transformHitTests: true,
            ),
            FadeEffect(
              duration: Duration(milliseconds: 1500),
              curve: Curves.easeIn,
            )
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.brainCircuit,
                size: 100,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(height: 20),
              Text(
                'Scientry',
                style: TextStyle(
                  fontSize: 60,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: 0.6 * MediaQuery.of(context).size.width,
                child: Divider(),
              ),
              SizedBox(height: 20),
              Text(
                'Science Simplifed,\nKnowledge Amplified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withAlpha((0.7 * 255).toInt()),
                ),
              ),
            ],
          ),
          onComplete: (controller) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
