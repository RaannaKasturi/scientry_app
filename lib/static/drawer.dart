import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/homepage.dart';

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 50, bottom: 30),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.brainCircuit,
                      size: 45,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      'Scientry',
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 40,
                  endIndent: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Science Simplified,\nKnowledge Amplified',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(LucideIcons.house),
                  title: Text(
                    'Home',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.search),
                  title: Text(
                    'Search',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.settings),
                  title: Text(
                    'Settings',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.send),
                  title: Text(
                    'Request Paper',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.messageCirclePlus),
                  title: Text(
                    'Request Feature',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  child: RichText(
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
                      url: "https://scietry.vercel.app/",
                      mode: Mode.platformDefault,
                    );
                  },
                ),
              ),
              InkWell(
                child: RichText(
                  text: TextSpan(
                    text: 'Designed & Developed by Nayan Kasturi',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                onTap: () {
                  EasyLauncher.url(
                    url: "https://nayankasturi.eu.org/",
                    mode: Mode.platformDefault,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      label: Text(
                        'Visit Site',
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ))),
                      icon: Icon(
                        LucideIcons.globe,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        EasyLauncher.url(
                          url: "https://scientry.vercel.app/",
                          mode: Mode.platformDefault,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
