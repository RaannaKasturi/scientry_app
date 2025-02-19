import 'dart:convert';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String _userProfile =
      "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";
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
      _userProfile = _prefs?.getString('userProfile') ??
          "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";
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

  void _changeProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Profile"),
          content: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 1,
              ),
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    "Take Photo",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () async {
                    bool cameraStatus = await Permission.camera.isGranted;
                    if (!cameraStatus) {
                      while (!(await Permission.camera.isGranted)) {
                        await Permission.camera.request();
                      }
                      final ImagePicker picker = ImagePicker();
                      final XFile? photo = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 100);
                      if (photo != null) {
                        final bytes = await photo.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        _prefs?.setString('userProfile', base64Image);
                        setState(() {
                          _userProfile = base64Image;
                        });
                      }
                      Navigator.pop(context);
                    } else {
                      final ImagePicker picker = ImagePicker();
                      final XFile? photo = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 100);
                      if (photo != null) {
                        final bytes = await photo.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        _prefs?.setString('userProfile', base64Image);
                        setState(() {
                          _userProfile = base64Image;
                        });
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    "Choose from Gallery",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () async {
                    bool photosStatus = await Permission.photos.isGranted;
                    if (!photosStatus) {
                      while (!(await Permission.photos.isGranted)) {
                        await Permission.photos.request();
                      }
                      final ImagePicker picker = ImagePicker();
                      final XFile? photo = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (photo != null) {
                        final bytes = await photo.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        _prefs?.setString('userProfile', base64Image);
                        setState(() {
                          _userProfile = base64Image;
                        });
                      }
                      Navigator.pop(context);
                    } else {
                      final ImagePicker picker = ImagePicker();
                      final XFile? photo = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (photo != null) {
                        final bytes = await photo.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        _prefs?.setString('userProfile', base64Image);
                        setState(() {
                          _userProfile = base64Image;
                        });
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
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
              onPressed: () {
                SystemNavigator.pop();
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: Image.memory(
                        base64Decode(_userProfile),
                        width: 120,
                        height: 120,
                      ).image,
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
                          onPressed: () {
                            _changeProfile(context);
                          },
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
                        : ListTile(
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
                            onTap: () {
                              _handleNotificationPermission();
                            },
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
                // OutlinedButton.icon(
                //   onPressed: () {
                //     EasyLauncher.url(
                //       url: "https://scientry.raannakasturi.eu.org",
                //       mode: Mode.platformDefault,
                //     );
                //   },
                //   icon: const Icon(LucideIcons.globe),
                //   label: Text(
                //     "Visit Us on the Web",
                //     style: TextStyle(
                //       fontSize: 20,
                //       color: Theme.of(context).colorScheme.onSurface,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
