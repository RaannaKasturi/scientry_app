import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final GlobalKey<FormBuilderState> _changeNameFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _changePasswordFormKey =
      GlobalKey<FormBuilderState>();

  // Initialize _name to "Set Name" so cache value will be used on load
  String _name = FirebaseAuth.instance.currentUser?.displayName ?? 'Set Name';
  String _email = FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    setCache();
  }

  void setCache() async {
    _prefs = await SharedPreferences.getInstance();
    String? cachedName = _prefs!.getString('userName');
    if (cachedName == null || cachedName == 'Set Name') {
      String firebaseName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Set Name';
      await _prefs!.setString('userName', firebaseName);
      cachedName = firebaseName;
    }
    String? cachedEmail = _prefs!.getString('userEmail');
    if (cachedEmail == null || cachedName == 'Set Email') {
      String firebaseEmail =
          FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
      await _prefs!.setString('userEmail', firebaseEmail);
      cachedEmail = firebaseEmail;
    }
    setState(() {
      _name = cachedName!;
      _email = cachedEmail!;
    });

    // The email logic remains unchanged.
    String firebaseEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
    await _prefs!.setString('userEmail', firebaseEmail);
  }

  _changeName() async {
    _prefs = await SharedPreferences.getInstance();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Change Name'),
          content: FormBuilder(
            key: _changeNameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  enableSuggestions: true,
                  initialValue: _name == 'Set Name' ? '' : _name,
                  name: 'name',
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    suffixIcon: IconButton(
                      onPressed: () {
                        _changeNameFormKey.currentState!.fields['name']!
                            .didChange('');
                      },
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (_changeNameFormKey.currentState!.saveAndValidate()) {
                    await FirebaseAuth.instance.currentUser!
                        .updateDisplayName(_name);
                    String userName =
                        FirebaseAuth.instance.currentUser!.displayName ?? _name;
                    await _prefs!.setString('userName', userName);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Name changed successfully'),
                      ),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _changePassword() async {
    _prefs = await SharedPreferences.getInstance();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Change Password'),
          content: FormBuilder(
            key: _changePasswordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Password must be at 8-20 characters long and must contain at least:\n1. one lowercase letter\n2. one uppercase letter\n3. one number\n4. one special character',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  name: 'password',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        _changePasswordFormKey.currentState!.fields['password']!
                            .didChange('');
                      },
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                    FormBuilderValidators.maxLength(20),
                    FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                    FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                    FormBuilderValidators.hasNumericChars(atLeast: 1),
                    FormBuilderValidators.hasSpecialChars(atLeast: 1),
                    (val) {
                      if (val !=
                          _changePasswordFormKey
                              .currentState!.fields['confirmpassword']!.value) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ]),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  name: 'confirmpassword',
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        _changePasswordFormKey
                            .currentState!.fields['confirmpassword']!
                            .didChange('');
                      },
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                    FormBuilderValidators.maxLength(20),
                    FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                    FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                    FormBuilderValidators.hasNumericChars(atLeast: 1),
                    FormBuilderValidators.hasSpecialChars(atLeast: 1),
                    (val) {
                      if (val !=
                          _changePasswordFormKey
                              .currentState!.fields['password']!.value) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (_changePasswordFormKey.currentState!.saveAndValidate()) {
                    await FirebaseAuth.instance.currentUser!.updatePassword(
                        _changePasswordFormKey
                            .currentState!.fields['password']!.value as String);
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Password changed successfully. Please Login Again.'),
                      ),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.logout,
              size: 25,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        title: Text(
          'My Account',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          ListBody(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Name',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Icon(LucideIcons.pen, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _name,
                        softWrap: true,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await _changeName();
                },
              ),
              Divider(
                indent: 25,
                endIndent: 25,
                height: 5,
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Email',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _email,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                indent: 25,
                endIndent: 25,
                height: 5,
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        LucideIcons.chevronRight,
                        size: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await _changePassword();
                },
              ),
              Divider(
                indent: 25,
                endIndent: 25,
                height: 5,
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account Support',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        LucideIcons.chevronRight,
                        size: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Implement Account Support
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
