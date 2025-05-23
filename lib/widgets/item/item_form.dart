import 'package:flutter/material.dart';

import '../../row_row_row_generated/tables/form.row.dart';

class ItemForm extends StatelessWidget {
  const ItemForm({
    super.key,
    required this.form,
    required this.theme,
    required this.onTap,
  });

  final ThemeData theme;
  final FormRow form;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.description, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.name ?? 'Untitled Form',
                    style: theme.textTheme.titleMedium,

                  ),
                  Text('${form.description}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
