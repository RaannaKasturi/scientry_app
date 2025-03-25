import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/screens/about_scientry.dart';
import 'package:scientry/screens/bookmarks_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:scientry/screens/login.dart';
import 'package:scientry/screens/my_account.dart';
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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _handleNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      setState(() {
        _notifications = true;
      });
    } else {
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
      _isLoggedIn = FirebaseAuth.instance.currentUser != null;
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
        ),
      ),
      bottomNavigationBar: ScientryBannerAd(),
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
                      goto() {
                        if (FirebaseAuth.instance.currentUser == null) {
                          return Login();
                        } else {
                          return MyAccount();
                        }
                      }

                      context.pushTransition(
                        curve: Curves.easeInOut,
                        type: PageTransitionType.rightToLeft,
                        child: goto(),
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
                      context.pushTransition(
                        curve: Curves.easeInOut,
                        type: PageTransitionType.rightToLeft,
                        child: BookmarksPage(),
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
                        if (_darkTheme) {
                          AnalyticsService()
                              .logAnalyticsEvent('dark_theme_disabled');
                        } else {
                          AnalyticsService()
                              .logAnalyticsEvent('dark_theme_enabled');
                        }
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
                  ListTile(
                    leading: Icon(
                      LucideIcons.info,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "About Scientry",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      context.pushTransition(
                        curve: Curves.easeInOut,
                        type: PageTransitionType.rightToLeft,
                        child: AboutScientry(),
                      );
                    },
                    trailing: Icon(
                      LucideIcons.chevronsRight,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.shieldUser,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      EasyLauncher.url(
                          url:
                              "https://scientry.binarybiology.top/app/privacy-policy",
                          mode: Mode.externalApp);
                    },
                    trailing: Icon(
                      LucideIcons.chevronsRight,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.handshake,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      EasyLauncher.url(
                          url:
                              "https://scientry.binarybiology.top/app/terms-and-conditions",
                          mode: Mode.externalApp);
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
                _isLoggedIn
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          AnalyticsService()
                              .logAnalyticsEvent('user_logged_out');
                          context.pushAndRemoveUntilTransition(
                            curve: Curves.easeInOut,
                            type: PageTransitionType.rightToLeft,
                            predicate: (route) => false,
                            child: HomePage(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logged out successfully"),
                            ),
                          );
                        },
                        label: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        icon: Icon(
                          LucideIcons.logOut,
                          color: Theme.of(context).colorScheme.error,
                          size: 25,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2.0,
                          ),
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
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
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      EasyLauncher.url(
                        url: "https://scientry.binarybiology.top/",
                        mode: Mode.externalApp,
                      );
                    },
                  ),
                ),
                InkWell(
                  child: Text(
                    "Brought to you by Binary Biology",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    EasyLauncher.url(
                      url: "https://binarybiology.top/",
                      mode: Mode.externalApp,
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
