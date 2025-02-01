import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/auth/login.dart';
import 'package:scientry/screens/change_name.dart';
import 'package:scientry/screens/change_password.dart';
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
  late final bool emailVerified;

  userData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      email = user!.email;
      name = user.displayName?.isNotEmpty == true
          ? user.displayName!
          : "Add your name";
      image = user.photoURL?.isNotEmpty == true
          ? user.photoURL!
          : "assets/images/profile_image_error.png";
      emailVerified = user.emailVerified;
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
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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

  userData();

  final screenWidth = MediaQuery.of(context).size.width;

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
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 125,
                          height: 125,
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircleAvatar(
                            backgroundImage: image.startsWith("http") == true
                                ? NetworkImage(image)
                                : AssetImage(image) as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            onPressed: (() {}),
                            icon: Icon(
                              LucideIcons.pen,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Column(
                      children: [
                        Text(
                          email!,
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  emailVerified == false
                                      ? OutlinedButton(
                                          onPressed: (() {
                                            verifyEmail();
                                          }),
                                          style: ButtonStyle(
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Verify Email",
                                            style: TextStyle(fontSize: 18),
                                          ))
                                      : Container(),
                                  OutlinedButton(
                                    onPressed: (() {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangeEmail(),
                                        ),
                                      );
                                    }),
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Change Email",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    onPressed: (() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangeName(),
                                        ),
                                      );
                                    }),
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Change Name",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: (() {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangePassword()));
                                    }),
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Change Password",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                width: 0.9 * screenWidth,
                child: ListTile(
                  title: Text(
                    'View Bookmarks',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  leading: Icon(Icons.bookmarks),
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: 0.8 * screenWidth,
                child: Divider(),
              ),
            ],
          ),
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: (() {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                }),
                label: Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                icon: Icon(Icons.logout),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  iconColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
      ),
    ),
  );
}
