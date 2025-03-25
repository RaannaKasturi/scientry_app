import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/screens/homepage.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({
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
              'assets/lottie/lost_connection.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Please check your internet connection",
              softWrap: true,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                iconColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                AnalyticsService().logAnalyticsEvent('homepage_visited');
                context.pushTransition(
                  curve: Curves.easeInOut,
                  type: PageTransitionType.size,
                  child: HomePage(),
                );
              },
              label: Text("Back to Home"),
              icon: Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }
}
