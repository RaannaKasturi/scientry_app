import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:scientry/screens/auth/login.dart';
import 'package:scientry/screens/profile.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormBuilderState> _passwordChangeFormKey =
      GlobalKey<FormBuilderState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> changePassword(BuildContext context) async {
    if (_passwordChangeFormKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        await user!.updatePassword(
            _passwordChangeFormKey.currentState!.fields['Password']!.value);
        showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: Text("Success"),
                content:
                    Text("Password changed successfully. Please Login Again."),
                actions: [
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
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
                  "An error occurred. Please try Logging Out and then Logging In again. \nError: ${e.toString()}"),
              actions: [
                TextButton(
                  onPressed: () {
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

  bool _obscureText = true;

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
        title: Text("Change Password"),
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.check),
            ),
            onPressed: () {
              changePassword(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: FormBuilder(
          key: _passwordChangeFormKey,
          child: Column(
            children: [
              FormBuilderTextField(
                obscureText: _obscureText,
                keyboardType: TextInputType.visiblePassword,
                enableSuggestions: true,
                name: "Password",
                focusNode: FocusNode(
                  canRequestFocus: true,
                ),
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: passwordController,
                decoration: InputDecoration(
                  helper: Text(
                    "Must be 8-20 characters, with at least one uppercase, one lowercase, one number, and one special character",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  label:
                      const Text("Password *", style: TextStyle(fontSize: 18)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
                autovalidateMode: AutovalidateMode.always,
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
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
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  label: const Text("Confirm Password *",
                      style: TextStyle(fontSize: 18)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
                  FormBuilderValidators.equal(passwordController.text,
                      errorText: "Passwords do not match"),
                ]),
                autovalidateMode: AutovalidateMode.always,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
