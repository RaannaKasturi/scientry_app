import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/info_pages/processing_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:scientry/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scientry/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _loginFormKey =
      GlobalKey<FormBuilderState>();
  bool _obscureText = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final processingText = "Logging in...";
  void _loginUser() async {
    _prefs = await SharedPreferences.getInstance();
    if (_loginFormKey.currentState!.saveAndValidate()) {
      ProcessingPage(processingText: processingText);
      try {
        var userEmail = _loginFormKey.currentState?.fields['Email *']?.value;
        var userPassword =
            _loginFormKey.currentState?.fields['Password *']?.value;
        UserCredential userCredentials =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );
        _prefs?.setString(
          'userName',
          userCredentials.user!.displayName ?? 'Set Name',
        );
        _prefs?.setString(
          'userEmail',
          userCredentials.user!.email ?? 'Set Email',
        );
        _prefs?.setString(
          'userUID',
          userCredentials.user!.photoURL ??
              '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',
        );
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        }
      } catch (e) {
        _loginFailed();
      }
    } else {
      _loginFailed();
    }
  }

  void _loginFailed() {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        body: Center(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/lottie/failed.json",
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  "Login failed!",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: (() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(LucideIcons.house),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.brainCircuit,
                    size: 48,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Scientry",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: 20),
              FormBuilder(
                key: _loginFormKey,
                child: Column(
                  children: [
                    // Email Field
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: FormBuilderTextField(
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: true,
                        name: "Email *",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          label: const Text("Email *",
                              style: TextStyle(fontSize: 18)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Password Field
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: FormBuilderTextField(
                        obscureText: _obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        enableSuggestions: true,
                        name: "Password *",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          helper: Text(
                            "Must be 8-20 characters, with at least one uppercase, one lowercase, one number, and one special character",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          label: const Text("Password *",
                              style: TextStyle(fontSize: 18)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.password(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.maxLength(20),
                          FormBuilderValidators.hasLowercaseChars(),
                          FormBuilderValidators.hasUppercaseChars(),
                          FormBuilderValidators.hasSpecialChars(),
                          FormBuilderValidators.hasNumericChars(),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: (() {
                        if (_loginFormKey.currentState!.saveAndValidate()) {
                          try {
                            _loginUser();
                          } catch (e) {
                            _loginFailed();
                          }
                        }
                      }),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primary),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                            LucideIcons.logIn,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
