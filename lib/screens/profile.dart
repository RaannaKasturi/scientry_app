import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/auth/change_name.dart';
import 'package:scientry/screens/auth/login.dart';
import 'package:scientry/screens/change_email.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? loggedProfile(context, true)
        : Login();
  }
}

Scaffold loggedProfile(BuildContext context, bool isLoggedIn) {
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

  verifyEmail() {
    try {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Email Sent", style: TextStyle(fontSize: 20)),
            content: Text("A verification link has been sent to your email."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error", style: TextStyle(fontSize: 20)),
            content: Text("An error occurred. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  final emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

  userData();
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
      ),
      leading: IconButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        icon: Icon(Icons.arrow_back),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          InkWell(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundImage: image
                                        .toString()
                                        .startsWith('assets')
                                    ? AssetImage("assets/images/john_doe.jpeg")
                                    : NetworkImage(image),
                              ),
                            ),
                            onTap: () {},
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 25,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(LucideIcons.pen, size: 20),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChangeName(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  email.toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withAlpha((0.5 * 255).toInt()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'View Bookmarks',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                leading: Icon(Icons.bookmarks),
                onTap: () {},
              ),
              Divider(),
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Email',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        emailVerified
                            ? Container()
                            : OutlinedButton(
                                onPressed: (() {
                                  verifyEmail();
                                }),
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.shieldCheck,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Verify",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                    leading: Icon(Icons.mail),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeEmail(),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(Icons.password),
                    onTap: () {},
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      'Logout',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    leading: Icon(
                      Icons.password,
                      color: Colors.red,
                    ),
                    onTap: () {},
                  ),
                  Divider(),
                ],
              ),
            ],
          ),
          Column(
            children: [
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
      ),
    ),
  );
}
