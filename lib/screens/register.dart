import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scientry/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final GlobalKey<FormBuilderState> _registerFormKey =
      GlobalKey<FormBuilderState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;
  SharedPreferences? _prefs;

  void _registerUser() async {
    if (_registerFormKey.currentState!.saveAndValidate()) {
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
                    "assets/lottie/processing.json",
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Registering...",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    try {
      var userEmail = _registerFormKey.currentState?.fields['Email *']?.value;
      var userName = _registerFormKey.currentState?.fields['name']?.value;
      var userPassword =
          _registerFormKey.currentState?.fields['Password *']?.value;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmail, password: userPassword);
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      await FirebaseAuth.instance.currentUser!.updateDisplayName(userName);
      User? currentUser = FirebaseAuth.instance.currentUser;
      String username = currentUser?.displayName.toString() ?? "Set Name";
      String useremail = currentUser!.email.toString();
      _prefs = await SharedPreferences.getInstance();
      _prefs?.setString('userEmail', useremail.toString());
      _prefs?.setString('userName', username.toString());
      AnalyticsService().logAnalyticsEvent('user_registered_with_email');
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
            "Registration successfully. Logging in...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Failed: $e");
      _registrationFailed(e);
    }
  }

  void _registrationFailed(e) {
    AnalyticsService().logAnalyticsEvent('user_registration_failed');
    String message = e.toString().split("]")[1].trim();
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Registration failed: $message",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.error,
                    ),
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

  void _registerWithGoogle() async {
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
      AnalyticsService().logAnalyticsEvent('user_registered_with_google');
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
            "Registration successfully. Logging in...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      );
    } catch (e) {
      _registrationFailed(e.toString());
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('registerpage_viewed');
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
                "Register",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: 20),
              FormBuilder(
                key: _registerFormKey,
                child: Column(
                  children: [
                    // Name Field
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: FormBuilderTextField(
                        keyboardType: TextInputType.name,
                        enableSuggestions: true,
                        name: "name",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          label: const Text("Name *",
                              style: TextStyle(fontSize: 18)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
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
                        controller: passwordController,
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
                          FormBuilderValidators.equal(
                              confirmPasswordController.text,
                              errorText: "Passwords do not match"),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: FormBuilderTextField(
                        obscureText: _obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        enableSuggestions: true,
                        name: "Confirm Password *",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          helper: Text(
                            "Re-enter your password",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          label: const Text("Confirm Password *",
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
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.password(),
                            FormBuilderValidators.minLength(8),
                            FormBuilderValidators.maxLength(20),
                            FormBuilderValidators.hasLowercaseChars(),
                            FormBuilderValidators.hasUppercaseChars(),
                            FormBuilderValidators.hasSpecialChars(),
                            FormBuilderValidators.hasNumericChars(),
                            FormBuilderValidators.equal(passwordController.text,
                                errorText: "Passwords do not match"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: (() {
                        if (_registerFormKey.currentState!.saveAndValidate()) {
                          try {
                            _registerUser();
                          } catch (e) {
                            debugPrint("Failed: 1 $e");
                            _registrationFailed(e);
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
                            LucideIcons.squarePen,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Register",
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
              isAndroid ? SizedBox(height: 20) : SizedBox.shrink(),
              isAndroid
                  ? ElevatedButton.icon(
                      onPressed: (() {
                        try {
                          _registerWithGoogle();
                        } catch (e) {
                          _registrationFailed(e.toString());
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
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  context.pushReplacementTransition(
                    curve: Curves.easeInOut,
                    type: PageTransitionType.rightToLeft,
                    child: Login(),
                  );
                },
                child: Text(
                  "Already have an account? Login",
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
