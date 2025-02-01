import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/profile.dart';
import 'package:scientry/static/processing_page.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final GlobalKey<FormBuilderState> _emailChangeKey =
      GlobalKey<FormBuilderState>();

  Future<void> changeEmail() async {
    ProcessingPage(processingText: "Changing Email...");
    if (_emailChangeKey.currentState!.saveAndValidate()) {
      final String emailChangeData =
          _emailChangeKey.currentState!.value["New Email *"];
      try {
        await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(
          emailChangeData,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
        }
        debugPrint('Email changed Email to $emailChangeData');
      } catch (e) {
        setState(() {
          emailChangeFailed = true;
        });
      }
    }
  }

  bool emailChangeFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Change Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          onPressed: (() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FormBuilder(
              key: _emailChangeKey,
              child: FormBuilderTextField(
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                name: "New Email *",
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  label:
                      const Text("New Email *", style: TextStyle(fontSize: 18)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Text(emailChangeFailed
                ? "Email change failed. Please try again."
                : ""),
          ),
          ElevatedButton(
            onPressed: (() {
              if (_emailChangeKey.currentState!.saveAndValidate()) {
                changeEmail();
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
                  LucideIcons.pen,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(width: 10),
                Text(
                  "Change Email",
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
    );
  }
}
