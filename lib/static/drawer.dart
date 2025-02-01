import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/auth/login.dart';
import 'package:scientry/screens/auth/register.dart';
import 'package:scientry/screens/profile.dart';

Column drawer(BuildContext context, isLoggedIn) {
  late final String? email;
  late final String name;
  late final String image;

  userData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      email = user!.email;
      name = user.displayName?.isNotEmpty == true
          ? user.displayName!
          : "Add your name";
      image = user.photoURL?.isNotEmpty == true
          ? user.photoURL!
          : "assets/images/john_doe.jpeg";
    } catch (e) {
      isLoggedIn = false;
    }
  }

  if (isLoggedIn) {
    userData();
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      isLoggedIn
          ? ExpansionTile(
              tilePadding:
                  EdgeInsets.only(top: 40, left: 12, right: 13, bottom: 5),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              collapsedBackgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              collapsedIconColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: image.toString().startsWith('assets')
                    ? AssetImage("assets/images/john_doe.jpeg")
                    : NetworkImage(image),
              ),
              title: Text(
                name,
                softWrap: true,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              subtitle: Text(
                email!,
                softWrap: true,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withAlpha((0.5 * 255).toInt()),
                ),
              ),
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        iconSize: 30,
                        onPressed: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(),
                            ),
                          );
                        }),
                        icon: Icon(LucideIcons.circleUserRound),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        iconSize: 30,
                        onPressed: (() {}),
                        icon: Icon(LucideIcons.settings),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        iconSize: 30,
                        onPressed: (() {
                          FirebaseAuth.instance.signOut();
                        }),
                        icon: Icon(
                          LucideIcons.logOut,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          : Container(
              padding: EdgeInsets.only(
                top: 50,
                bottom: 20,
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "You're not logged in",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    "Please Login to bookmark the posts",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withAlpha((0.5 * 255).toInt()),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ),
                          );
                        }),
                        label: Text(
                          "SignUp",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          LucideIcons.squarePen,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        }),
                        label: Text(
                          "LogIn",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          LucideIcons.logIn,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 25),
              ),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'About',
                style: TextStyle(fontSize: 25),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
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
                        color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.primary,
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
                IconButton(
                  icon: Icon(
                    LucideIcons.globe,
                    size: 30,
                    color: Colors.black,
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
  );
}

class LoginState extends StatelessWidget {
  const LoginState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return drawer(context, true);
        } else {
          return drawer(context, false);
        }
      },
    );
  }
}
