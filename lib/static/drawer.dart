import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/screens/bookmarks_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:scientry/screens/login.dart';
import 'package:scientry/screens/request_paper.dart';
import 'package:scientry/screens/search_page.dart';
import 'package:scientry/screens/settings_page.dart';

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 40, bottom: 10),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.brainCircuit,
                          size: 35,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          'Scientry',
                          style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 75),
                      child: Divider(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Science Simplified,\nKnowledge Amplified',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !isLoggedIn
                        ? ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.pushTransition(
                                curve: Curves.easeInOut,
                                type: PageTransitionType.rightToLeft,
                                child: Login(),
                              );
                            },
                            label: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 20,
                              ),
                            ),
                            icon: Icon(
                              Icons.login,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: false,
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(LucideIcons.house),
                      title: Text(
                        'Home',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushReplacementTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: HomePage(),
                        );
                      },
                    ),
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      height: 5,
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.bookmark),
                      title: Text(
                        'Bookmarks',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
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
                      leading: Icon(LucideIcons.search),
                      title: Text(
                        'Search',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: SearchPage(),
                        );
                      },
                    ),
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      height: 5,
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.send),
                      title: Text(
                        'Request Paper',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: RequestPaper(),
                        );
                      },
                    ),
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      height: 5,
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.messageCirclePlus),
                      title: Text(
                        'Request Feature',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        if (isLoggedIn) {
                          Navigator.pop(context);
                          EasyLauncher.email(
                            email: "scientry@binarybiology.top",
                            subject: "Feature Request for Scientry (Android)",
                          );
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please login to request a feature"),
                            ),
                          );
                        }
                      },
                    ),
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      height: 5,
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.settings),
                      title: Text(
                        'Settings',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: SettingsPage(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              isLoggedIn
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        children: [
                          Divider(
                            indent: 25,
                            endIndent: 25,
                            height: 5,
                          ),
                          ListTile(
                            leading: Icon(
                              LucideIcons.logOut,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pop(context);
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
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
