import 'package:flutter/material.dart';

class DefaultIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const DefaultIconButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Text(text),
      icon: Icon(icon),
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
    );
  }
}
