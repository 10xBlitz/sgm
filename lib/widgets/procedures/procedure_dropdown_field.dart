import 'package:flutter/material.dart';

class ProcedureDropdownField extends StatelessWidget {
  const ProcedureDropdownField({
    super.key,
    this.showLabel = true,
    required this.label,
    required this.value,
    required this.items,
    required this.isLoading,
    required this.onChanged,
  });

  final bool showLabel;
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) Text(label, style: const TextStyle(fontSize: 16)),
        if (showLabel) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              value: value,
              hint: const Text('Select...'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: items,
              onChanged: isLoading ? null : onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
