import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPosts extends StatelessWidget {
  const LoadingPosts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/loading.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Loading Posts...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              "Please Wait!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Based on your network speed,",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              "this may take a while...",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
