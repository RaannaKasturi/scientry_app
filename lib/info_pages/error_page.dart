import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.errorPageText,
  });

  final String errorPageText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/lottie/failed.json",
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  errorPageText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
