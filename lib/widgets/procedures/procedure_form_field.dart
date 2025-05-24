import 'package:flutter/material.dart';

class ProcedureFormField extends StatelessWidget {
  const ProcedureFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.showLabel = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final bool showLabel;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) Text(label, style: const TextStyle(fontSize: 16)),
        if (showLabel) const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
