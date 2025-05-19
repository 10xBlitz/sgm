import 'package:flutter/material.dart';

class SideNavButton extends StatelessWidget {
  const SideNavButton({
    super.key,
    required this.onTapNav,
    required this.title,
    required this.selectedNav,
  });

  final String title;
  final Future<void> Function(String targetTab) onTapNav;
  final String selectedNav;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedNav == title;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        await onTapNav(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                width: 32,
                child: Icon(
                  Icons.dashboard,
                  color:
                      isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
