import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:scientry/onboarding/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                WidgetSpan(
                  child: Text(
                    "By continuing you agree to our ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                WidgetSpan(
                  child: InkWell(
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    onTap: () {
                      EasyLauncher.url(
                        url:
                            "https://scientry.binarybiology.top/app/privacy-policy",
                        mode: Mode.platformDefault,
                      );
                    },
                  ),
                ),
                WidgetSpan(
                  child: Text(
                    " and ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                WidgetSpan(
                  child: InkWell(
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    onTap: () {
                      EasyLauncher.url(
                        url:
                            "https://scientry.binarybiology.top/app/terms-and-conditions",
                        mode: Mode.platformDefault,
                      );
                    },
                  ),
                ),
              ],
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/brand/scientry_launcher_icon.png',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Welcome to Scientry",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Get the latest research papers and articles from the top publishers around the world in form of AI-Generated Summaries and Mindmaps.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: TextButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () {
                  context.pushReplacementTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: RequestNotificationsPermission(),
                  );
                  final prefs =
                      Provider.of<SharedPreferences>(context, listen: false);
                  prefs.setBool('firstTime', false);
                },
                label: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: Theme.of(context).textTheme.titleLarge!.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
