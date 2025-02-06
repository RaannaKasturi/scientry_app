import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  final GlobalKey<FormBuilderState> _nameFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _emailFormKey =
      GlobalKey<FormBuilderState>();

  String _userName = "Set Name";
  String _userEmail = "Set Email";
  bool _darkTheme = false;
  bool _notifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _handleNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      setState(() {
        _notifications = !_notifications;
      });
    } else {
      PermissionStatus newStatus = await Permission.notification.request();
      if (newStatus.isGranted) {
        setState(() {
          _notifications = true;
        });
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "Notifications are disabled. Please enable them in settings."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
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
      _userName = _prefs?.getString('userName') ?? "Set Name";
      _userEmail = _prefs?.getString('userEmail') ?? "Set Email";
    });
  }

  void _changeName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Name"),
          content: FormBuilder(
            key: _nameFormKey,
            child: FormBuilderTextField(
              name: "name",
              initialValue: _userName,
              decoration: InputDecoration(
                labelText: "Name",
                suffixIcon: IconButton(
                  onPressed: () {
                    _nameFormKey.currentState!.fields["name"]!.didChange("");
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_nameFormKey.currentState!.saveAndValidate()) {
                  var name = _nameFormKey.currentState!.fields["name"]!.value;
                  _prefs?.setString('userName', name);
                  setState(() {
                    _userName = name;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _changeEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Email"),
          content: FormBuilder(
            key: _emailFormKey,
            child: FormBuilderTextField(
              name: "email",
              initialValue: _userEmail,
              decoration: InputDecoration(
                labelText: "Email",
                suffixIcon: IconButton(
                  onPressed: () {
                    _emailFormKey.currentState!.fields["email"]!.didChange("");
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_emailFormKey.currentState!.saveAndValidate()) {
                  var email =
                      _emailFormKey.currentState!.fields["email"]!.value;
                  _prefs?.setString('userEmail', email);
                  setState(() {
                    _userEmail = email;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
              onPressed: () {},
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
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/images/person.png"),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  child: Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    _changeName(context);
                  },
                ),
                InkWell(
                  child: Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    _changeEmail(context);
                  },
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).colorScheme.onSurface,
                  thickness: 1,
                  indent: 35,
                  endIndent: 35,
                ),
                const SizedBox(height: 10),
                ListBody(
                  children: [
                    ListTile(
                      leading: Icon(
                        LucideIcons.sunMoon,
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
                    ListTile(
                      leading: Icon(
                        LucideIcons.bellPlus,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        "Get Notifications",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: _notifications,
                        onChanged: (_) => _handleNotificationPermission(),
                      ),
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
                  ],
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Made with 💖 by Nayan Kasturi",
                    ),
                  ),
                  onTap: () {
                    EasyLauncher.url(
                      url: "https://nayankasturi.eu.org",
                      mode: Mode.platformDefault,
                    );
                  },
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    EasyLauncher.url(
                      url: "https://scientry.raannakasturi.eu.org",
                      mode: Mode.platformDefault,
                    );
                  },
                  icon: const Icon(LucideIcons.globe),
                  label: Text(
                    "Visit Us on the Web",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
