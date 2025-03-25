import 'package:flutter/material.dart';

class SetContentPreferences extends StatefulWidget {
  const SetContentPreferences({super.key});

  @override
  State<SetContentPreferences> createState() => _SetContentPreferencesState();
}

class _SetContentPreferencesState extends State<SetContentPreferences> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Content Preferences',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Set Content Preferences'),
      ),
    );
  }
}
