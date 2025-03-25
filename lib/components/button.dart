import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const DefaultButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        foregroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.onPrimary,
        ),
        iconColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
