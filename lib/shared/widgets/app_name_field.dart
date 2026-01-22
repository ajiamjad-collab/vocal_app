import 'package:flutter/material.dart';

class AppNameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputAction textInputAction;

  const AppNameField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.name,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.name],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }
}
