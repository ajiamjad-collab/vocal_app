import 'package:flutter/material.dart';

class AppEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AppEmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
    );
  }
}
