import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/profile.dart';
import 'package:scientry/static/processing_page.dart';

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  final GlobalKey<FormBuilderState> _nameChangeKey =
      GlobalKey<FormBuilderState>();

  Future<void> changeName() async {
    ProcessingPage(processingText: "Changing Name...");
    if (_nameChangeKey.currentState!.saveAndValidate()) {
      final String nameChangeData =
          _nameChangeKey.currentState!.value["New Name *"];
      try {
        await FirebaseAuth.instance.currentUser!.updateDisplayName(
          nameChangeData,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
        }
        debugPrint('Name changed name to $nameChangeData');
      } catch (e) {
        setState(() {
          nameChangeFailed = true;
        });
      }
    }
  }

  bool nameChangeFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Change Name',
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
              key: _nameChangeKey,
              child: FormBuilderTextField(
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                name: "New Name *",
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  label:
                      const Text("New Name *", style: TextStyle(fontSize: 18)),
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
            child: Text(nameChangeFailed
                ? "Name change failed. Please try again."
                : ""),
          ),
          ElevatedButton(
            onPressed: (() {
              if (_nameChangeKey.currentState!.saveAndValidate()) {
                changeName();
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
                  "Change Name",
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
