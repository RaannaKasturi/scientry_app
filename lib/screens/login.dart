import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/info_pages/processing_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:scientry/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scientry/screens/reset_password.dart';
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
        AnalyticsService().logAnalyticsEvent('user_loggedin_with_email');
        if (mounted) {
          context.pushAndRemoveUntilTransition(
            curve: Curves.easeInOut,
            type: PageTransitionType.rightToLeft,
            predicate: (route) => false,
            child: HomePage(),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: Text(
              "Logged in successfully",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        );
      } catch (e) {
        _loginFailed(e);
      }
    } else {
      _loginFailed('Login failed due to Unknown Reasons');
    }
  }

  void _loginFailed(e) {
    AnalyticsService().logAnalyticsEvent('user_login_failed');
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
                  e.toString(),
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
                    context.pushAndRemoveUntilTransition(
                      curve: Curves.easeInOut,
                      type: PageTransitionType.rightToLeft,
                      predicate: (route) => false,
                      child: HomePage(),
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

  void _loginWithGoogle() async {
    final auth = FirebaseAuth.instance;
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      _prefs?.setString(
          'userName', userCredential.user!.displayName ?? 'Set Name');
      _prefs?.setString('userEmail', userCredential.user!.email ?? 'Set Email');
      AnalyticsService().logAnalyticsEvent('user_loggedin_with_google');
      context.pushAndRemoveUntilTransition(
        curve: Curves.easeInOut,
        type: PageTransitionType.rightToLeft,
        predicate: (route) => false,
        child: HomePage(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            "Logged in successfully",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("GLOGIN: ${e.toString()}");
      _loginFailed(e.toString());
    }
    return null;
  }

  bool isAndroidFunction() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('loginpage_visited');
    bool isAndroid = isAndroidFunction();
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
                context.pushAndRemoveUntilTransition(
                  curve: Curves.easeInOut,
                  type: PageTransitionType.rightToLeft,
                  predicate: (route) => false,
                  child: HomePage(),
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
                            _loginFailed(e.toString());
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
                    isAndroid ? SizedBox(height: 20) : SizedBox.shrink(),
                    isAndroid
                        ? ElevatedButton.icon(
                            onPressed: (() {
                              try {
                                _loginWithGoogle();
                              } catch (e) {
                                _loginFailed(e.toString());
                              }
                            }),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            label: Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            icon: Icon(
                              FontAwesomeIcons.google,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  context.pushReplacementTransition(
                    curve: Curves.easeInOut,
                    type: PageTransitionType.rightToLeft,
                    child: Register(),
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
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  context.pushReplacementTransition(
                    curve: Curves.easeInOut,
                    type: PageTransitionType.rightToLeft,
                    child: ResetPassword(),
                  );
                },
                child: Text(
                  "Forgot Password? Reset your password",
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
