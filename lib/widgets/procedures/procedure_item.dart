import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';

class ProcedureItem extends StatelessWidget {
  const ProcedureItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.theme,
  });

  final ProcedureWithCategoryClinicAreaNamesRow item;
  final ThemeData theme;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.clinicName ?? 'Untitled Clinic',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description ?? 'No description available',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8.0,
                      //     vertical: 4.0,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: theme.colorScheme.primaryContainer,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Text(
                      //     item. ?? 'No Status',
                      //     style: theme.textTheme.labelSmall?.copyWith(
                      //       color: theme.colorScheme.onPrimaryContainer,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.createdAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
