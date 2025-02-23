import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scientry/api/notification_service.dart';
import 'package:scientry/screens/bookmarks_page.dart';
import 'package:scientry/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? _prefs;

  bool _darkTheme = false;
  bool _notifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _handleNotificationPermission() async {
    // First request for permission
    PermissionStatus status = await Permission.notification.request();

    // If not granted, try to request again
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      setState(() {
        _notifications = true;
      });
    } else {
      // If the permission is permanently denied, the system won’t show the prompt again.
      // Prompt the user to open the app settings to enable the permission manually.
      if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "Notifications permission is permanently denied. Please enable it in the app settings."),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: const Text("Open Settings"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "Notifications permission was not granted. Would you like to try again?"),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    PermissionStatus newStatus =
                        await Permission.notification.request();
                    if (newStatus.isGranted) {
                      setState(() {
                        _notifications = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Permission not granted. Please enable notifications in settings."),
                        ),
                      );
                    }
                  },
                  child: const Text("Try Again"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Permission not granted. Please enable notifications in settings."),
            ),
          );
        }
      }
    }
  }

  Future<bool> getNotificationStatus() async {
    var status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    bool notificationGranted = await getNotificationStatus();
    setState(() {
      _notifications = notificationGranted;
      _darkTheme = _prefs?.getBool('darkTheme') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 25,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.logout,
                size: 25,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              ListBody(
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.user,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "My Account",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronsRight,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookmarksPage(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.bookMarked,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "Bookmarks",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronsRight,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookmarksPage(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(
                      _darkTheme ? LucideIcons.sun : LucideIcons.moon,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "Dark Theme",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      bool value = !_darkTheme;
                      setState(() {
                        _prefs?.setBool('darkTheme', value);
                        _darkTheme = value;
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      });
                    },
                    trailing: Switch.adaptive(
                      value: _darkTheme,
                      onChanged: (_) {
                        bool value = !_darkTheme;
                        setState(() {
                          _prefs?.setBool('darkTheme', value);
                          _darkTheme = value;
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        });
                      },
                    ),
                  ),
                  _notifications
                      ? const SizedBox()
                      : Divider(
                          indent: 25,
                          endIndent: 25,
                          height: 5,
                        ),
                  _notifications
                      ? const SizedBox()
                      : ListTile(
                          leading: Icon(
                            LucideIcons.bellPlus,
                            size: 30,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          title: Text(
                            "Daily Reminder",
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          onTap: () {
                            _handleNotificationPermission();
                          },
                          trailing: Switch.adaptive(
                            value: _notifications,
                            onChanged: (_) => _handleNotificationPermission(),
                          ),
                        ),
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    height: 5,
                  ),
                  !_notifications
                      ? const SizedBox()
                      : ListTile(
                          leading: Icon(
                            LucideIcons.bellPlus,
                            size: 30,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          title: Text(
                            "Set Reminder Time",
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          onTap: () {
                            NotificationService().showNotification(
                              title: "Test Notification",
                              body:
                                  "Test Notification description is it working..?",
                            );
                          },
                          trailing: Icon(
                            LucideIcons.chevronsRight,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ],
              )
            ],
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: InkWell(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(LucideIcons.copyright, size: 15),
                                ),
                                TextSpan(
                                  text: ' 2024 Scientry',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '\nv${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url: "https://scietry.vercel.app/",
                              mode: Mode.platformDefault,
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                InkWell(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Made with 💖 by Nayan Kasturi",
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onTap: () {
                    EasyLauncher.url(
                      url: "https://nayankasturi.eu.org",
                      mode: Mode.platformDefault,
                    );
                  },
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
