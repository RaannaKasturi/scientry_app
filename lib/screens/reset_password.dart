import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scientry/screens/login.dart';
import 'package:scientry/screens/register.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormBuilderState> _resetPasswordFormKey =
      GlobalKey<FormBuilderState>();

  void _resetPassword() async {
    if (_resetPasswordFormKey.currentState!.saveAndValidate()) {
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
                    "Sending password reset link...",
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
      var userEmail =
          _resetPasswordFormKey.currentState?.fields['email']?.value;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
      AnalyticsService().logAnalyticsEvent('user_password_reset_requested');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            maxLines: 2,
            "Password reset email sent to $userEmail. Check your email to reset your password.",
          ),
          duration: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        context.pushReplacementTransition(
          curve: Curves.easeInOut,
          type: PageTransitionType.rightToLeft,
          child: Login(),
        );
      }
    } catch (e) {
      String message = e.toString().split("]")[1].trim();
      debugPrint("Failed: $e");
      ErrorPage(errorPageText: message);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('passwordresetpage_viewed');
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
                context.pushTransition(
                  curve: Curves.easeInOut,
                  type: PageTransitionType.rightToLeft,
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
                "Reset Password",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: 20),
              FormBuilder(
                key: _resetPasswordFormKey,
                child: Column(
                  children: [
                    // Email Field
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: FormBuilderTextField(
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: true,
                        name: "email",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          label: const Text(
                            "Email *",
                            style: TextStyle(fontSize: 18),
                          ),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (() {
                        if (_resetPasswordFormKey.currentState!
                            .saveAndValidate()) {
                          try {
                            _resetPassword();
                          } catch (e) {
                            String message = e.toString().split("]")[1].trim();
                            ErrorPage(errorPageText: message);
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
                            "Reset Password",
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
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      context.pushTransition(
                        curve: Curves.easeInOut,
                        type: PageTransitionType.rightToLeft,
                        child: Login(),
                      );
                    },
                    label: Text(
                      'Login',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    icon: Icon(
                      Icons.login,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.pushTransition(
                        curve: Curves.easeInOut,
                        type: PageTransitionType.rightToLeft,
                        child: Register(),
                      );
                    },
                    label: Text(
                      'Register',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    icon: Icon(
                      Icons.app_registration,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
