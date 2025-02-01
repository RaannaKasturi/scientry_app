import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:scientry/screens/profile.dart';

class ChangeName extends StatelessWidget {
  ChangeName({super.key});

  final GlobalKey<FormBuilderState> _nameChangeFormKey =
      GlobalKey<FormBuilderState>();

  changeName(BuildContext context) {
    if (_nameChangeFormKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        user!.updateDisplayName(
            _nameChangeFormKey.currentState!.fields['Name']!.value);
        showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Name changed successfully"),
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
              );
            }));
      } catch (e) {
        showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(
                  "An error occurred. Please try again in some time. \nError: ${e.toString()}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          }),
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
        title: Text("Change Name"),
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.check),
            ),
            onPressed: () {
              changeName(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: FormBuilder(
              key: _nameChangeFormKey,
              child: FormBuilderTextField(
                name: 'Name',
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.text,
                autocorrect: true,
                enableSuggestions: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(3),
                ]),
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  label: const Text("Name *", style: TextStyle(fontSize: 18)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
