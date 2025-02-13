import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/bookmarks_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:scientry/screens/request_paper.dart';
import 'package:scientry/screens/search_page.dart';
import 'package:scientry/screens/settings_page.dart';

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
                    fontSize: 15,
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
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.bookmark),
                  title: Text(
                    'Bookmarks',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookmarksPage()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.search),
                  title: Text(
                    'Search',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.settings),
                  title: Text(
                    'Settings',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.send),
                  title: Text(
                    'Request Paper',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RequestPaper()));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.messageCirclePlus),
                  title: Text(
                    'Request Feature',
                    style: TextStyle(fontSize: 20),
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
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
