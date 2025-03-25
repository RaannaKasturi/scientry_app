import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/screens/homepage.dart';
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
  final GlobalKey<FormBuilderState> _deleteAccountFormKey =
      GlobalKey<FormBuilderState>();

  String _name = FirebaseAuth.instance.currentUser?.displayName ?? 'Set Name';
  String _email = FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
  SharedPreferences? _prefs;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    setCache();
  }

  void setCache() async {
    _prefs = await SharedPreferences.getInstance();
    String? cachedName = _prefs!.getString('userName');
    if (cachedName == 'Set Name') {
      String firebaseName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Set Name';
      await _prefs!.setString('userName', firebaseName);
      cachedName = firebaseName;
    }
    String? cachedEmail = _prefs!.getString('userEmail');
    if (cachedName == 'Set Email') {
      String firebaseEmail =
          FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
      await _prefs!.setString('userEmail', firebaseEmail);
      cachedEmail = firebaseEmail;
    }
    setState(() {
      _name = cachedName!;
      _email = cachedEmail!;
    });
    String firebaseEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Set Email';
    await _prefs!.setString('userEmail', firebaseEmail);
  }

  _clearUserAccountPreferences() {
    _prefs!.remove('userName');
    _prefs!.remove('userEmail');
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
                  AnalyticsService().logAnalyticsEvent('user_name_changed');
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Change Password'),
              content: SingleChildScrollView(
                child: FormBuilder(
                  key: _changePasswordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Password must be 8-20 characters long and contain at least:\n'
                        '1. One lowercase letter\n'
                        '2. One uppercase letter\n'
                        '3. One number\n'
                        '4. One special character',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        enableSuggestions: true,
                        name: "password",
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          helperText:
                              "Must be 8-20 characters, with at least one uppercase, one lowercase, one number, and one special character",
                          label: Text("Password *",
                              style: TextStyle(fontSize: 18)),
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.maxLength(20),
                          FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                          FormBuilderValidators.hasUppercaseChars(atLeast: 1),
                          FormBuilderValidators.hasNumericChars(atLeast: 1),
                          FormBuilderValidators.hasSpecialChars(atLeast: 1),
                          (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (val !=
                                _changePasswordFormKey
                                    .currentState?.fields['password']?.value) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ]),
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        enableSuggestions: false,
                        name: 'confirmpassword',
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.maxLength(20),
                          FormBuilderValidators.hasLowercaseChars(atLeast: 1),
                          FormBuilderValidators.hasUppercaseChars(atLeast: 1),
                          FormBuilderValidators.hasNumericChars(atLeast: 1),
                          FormBuilderValidators.hasSpecialChars(atLeast: 1),
                          (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (val !=
                                _changePasswordFormKey
                                    .currentState?.fields['password']?.value) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ]),
                      ),
                    ],
                  ),
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
                      if (_changePasswordFormKey.currentState!
                          .saveAndValidate()) {
                        await FirebaseAuth.instance.currentUser!.updatePassword(
                            _changePasswordFormKey.currentState!
                                .fields['password']!.value as String);
                        FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                        context.pushAndRemoveUntilTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          predicate: (route) => false,
                          child: HomePage(),
                        );
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: Login(),
                        );
                        AnalyticsService()
                            .logAnalyticsEvent('user_password_changed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Password changed successfully. Please log in again.'),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
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
      },
    );
  }

  _sendVerificationMail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Verification email sent to ${FirebaseAuth.instance.currentUser!.email}'),
      ),
    );
  }

  _handleAccountDeletion() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Account'),
              content: FormBuilder(
                key: _deleteAccountFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      enableSuggestions: true,
                      name: 'deletionpassword',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Password to Delete Account',
                        suffixIcon: IconButton(
                          onPressed: () {
                            _deleteAccountFormKey
                                .currentState!.fields['deletionpassword']!
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
                        FormBuilderValidators.hasUppercaseChars(atLeast: 1),
                        FormBuilderValidators.hasNumericChars(atLeast: 1),
                        FormBuilderValidators.hasSpecialChars(atLeast: 1),
                      ]),
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
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (_deleteAccountFormKey.currentState!
                          .saveAndValidate()) {
                        await FirebaseAuth.instance.currentUser!
                            .reauthenticateWithCredential(
                          EmailAuthProvider.credential(
                            email: _email,
                            password: _deleteAccountFormKey.currentState!
                                .fields['deletionpassword']!.value,
                          ),
                        );
                        await FirebaseAuth.instance.currentUser!.delete();
                        await FirebaseAuth.instance.signOut();
                        await _clearUserAccountPreferences();
                        Navigator.pop(context);
                        context.pushAndRemoveUntilTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          predicate: (route) => false,
                          child: HomePage(),
                        );
                        AnalyticsService()
                            .logAnalyticsEvent('user_account_deleted');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Account Deleted Successfully')),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      String message = e.toString();
                      debugPrint(
                          "DData: ${message.split('/')[1].split(']')[0]}");
                      if ((message.split('/')[1].split(']')[0])
                              .startsWith("invalid-credential") ||
                          (message.split('/')[1].split(']')[0])
                              .startsWith("wrong-password")) {
                        message =
                            'Incorrect Password or password setup is incomplete. Please change or reset password and try again.';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('myaccountpage_viewed');
    bool isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
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
              context.pushAndRemoveUntilTransition(
                curve: Curves.easeInOut,
                type: PageTransitionType.rightToLeft,
                predicate: (route) => false,
                child: HomePage(),
              );
              AnalyticsService().logAnalyticsEvent('user_logged_out');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                ),
              );
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
      bottomNavigationBar: ScientryBannerAd(),
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
                    Text(
                      'Email ${isEmailVerified ? '' : '(Unverified)'}',
                      style: TextStyle(
                        color: isEmailVerified
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.error,
                        fontSize: 18,
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
                onTap: () {
                  if (!isEmailVerified) {
                    AnalyticsService()
                        .logAnalyticsEvent('user_email_verification_requested');
                    _sendVerificationMail();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email already verified'),
                      ),
                    );
                  }
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
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: Login(),
                        );
                      },
                      icon: Icon(
                        LucideIcons.chevronRight,
                        size: 25,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  context.pushAndRemoveUntilTransition(
                    curve: Curves.easeInOut,
                    type: PageTransitionType.rightToLeft,
                    predicate: (route) => false,
                    child: HomePage(),
                  );
                  AnalyticsService().logAnalyticsEvent('user_logged_out');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      content: Text(
                        "Logged out successfully",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  );
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
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          await _handleAccountDeletion();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        LucideIcons.chevronRight,
                        size: 25,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  try {
                    await _handleAccountDeletion();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
