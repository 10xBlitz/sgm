# Instructions

## Widget Structure

When suggesting widgets:
- Always prefer `const` constructors when possible
- Use named parameters for clarity
- Follow trailing comma convention for better formatting
- Group related parameters together

## Screen Structure Pattern

When creating a new screen, follow this pattern:

```dart
import 'package:flutter/material.dart';

class ExampleScreen extends StatefulWidget {
  static const routeName = "/example";
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Screen content here
          ],
        ),
      ),
    );
  }
}
```

## Be a Never Nester
- Limit nesting too much into 1 or 2 levels only.