import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scientry/components/icon_button.dart';
import 'package:scientry/screens/homepage.dart';

class RequestNotificationsPermission extends StatefulWidget {
  const RequestNotificationsPermission({super.key});

  @override
  State<RequestNotificationsPermission> createState() =>
      _RequestNotificationsPermissionState();
}

Future<void> notificationsPermission(BuildContext context) async {
  var notiStatus = await Permission.notification.status;

  if (notiStatus.isGranted) {
    _navigateToHome(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notifications already enabled")),
    );
    return;
  }

  try {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      _navigateToHome(context);
    } else {
      showPermissionExplanationDialog(context);
    }
  } catch (e) {
    showPermissionExplanationDialog(context);
  }
}

void _navigateToHome(BuildContext context) {
  Navigator.pushReplacement(
    context,
    PageTransition(
      child: const HomePage(),
      type: PageTransitionType.fade,
    ),
  );
}

void showPermissionExplanationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Permission Required"),
      content: const Text("Enable notifications in settings"),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: const Text("Open Settings"),
        ),
        TextButton(
          onPressed: () => _navigateToHome(context),
          child: const Text("Continue Anyway"),
        ),
      ],
    ),
  );
}

class _RequestNotificationsPermissionState
    extends State<RequestNotificationsPermission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Allow Scientry to send you notifications?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "We will notify you about the latest papers daily to keep you updated with the latest in the research.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            DefaultIconButton(
              onPressed: () async {
                await notificationsPermission(context);
              },
              text: "Allow Notifications",
              icon: Icons.notifications,
            ),
          ],
        ),
      ),
    );
  }
}
