import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Column drawer(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 10),
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        minRadius: 25,
                        maxRadius: 25,
                        backgroundImage:
                            AssetImage("assets/images/john_doe.jpeg"),
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          "assets/images/johdn_doe.jpeg",
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                                'assets/images/profile_image_error.png');
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "John Doe",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 25,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          Text("johndoe@example.com",
                              softWrap: true,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withAlpha((0.6 * 255).toInt()),
                              )),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      debugPrint("Account Details");
                    },
                    icon: Icon(LucideIcons.chevronDown),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      'Home',
                      style: TextStyle(fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'About',
                      style: TextStyle(fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Contact',
                      style: TextStyle(fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: RichText(
              text: TextSpan(children: [
                WidgetSpan(child: Icon(LucideIcons.copyright, size: 15)),
                TextSpan(
                  text: ' 2024 Scientry',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              top: 5,
            ),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Designed & Developed by ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: 'Nayan Kasturi',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      try {
                        await EasyLauncher.url(
                          url: "https://nayankasturi.eu.org/",
                          mode: Mode.platformDefault,
                        );
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    LucideIcons.instagram,
                    size: 30,
                    color: Colors.purple,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.mail,
                    size: 30,
                    color: Colors.red,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.linkedin,
                    size: 30,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.youtube,
                    size: 30,
                    color: Colors.red,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
