import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:scientry/screens/profile.dart';

class ChangeEmail extends StatelessWidget {
  ChangeEmail({super.key});

  final GlobalKey<FormBuilderState> _emailChangeFormKey =
      GlobalKey<FormBuilderState>();

  changeEmail(BuildContext context) async {
    if (_emailChangeFormKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("No user is signed in. Please log in and try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      String newEmail =
          _emailChangeFormKey.currentState!.fields['Email']!.value;

      try {
        // Prompt user to re-enter password
        String? password = await showDialog<String>(
          context: context,
          builder: (context) {
            TextEditingController passwordController = TextEditingController();
            return AlertDialog(
              title: Text("Re-authentication Required"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Please enter your password to continue."),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, passwordController.text),
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );

        if (password == null || password.isEmpty) return; // User canceled

        // Reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

        // After successful reauthentication, proceed with email change
        await user.verifyBeforeUpdateEmail(newEmail);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content:
                Text("A verification email has been sent to your new email."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ),
                  );
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred: ${e.toString()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Profile();
            }));
          },
        ),
        title: Text("Change Email"),
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.check),
            ),
            onPressed: () {
              changeEmail(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: FormBuilder(
              key: _emailChangeFormKey,
              child: FormBuilderTextField(
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                name: "Email *",
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  label: const Text("Email *", style: TextStyle(fontSize: 18)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
                autovalidateMode: AutovalidateMode.onUnfocus,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
