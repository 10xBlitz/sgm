# Seoul Guide Medical - Code Patterns for GitHub Copilot

This document describes common code patterns used in the Seoul Guide Medical Flutter application to help GitHub Copilot provide more consistent and project-specific suggestions.

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

## Service Pattern

When creating a new service, follow this pattern:

```dart
import 'package:flutter/foundation.dart';

class ExampleService extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  
  // Public getters
  bool get isLoading => _isLoading;
  
  // Methods that change state should call notifyListeners()
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Implementation
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Global instance for easy access
final exampleService = ExampleService();
```

## Router Configuration Pattern

When adding a new route:

```dart
// Add route to the router.dart file
GoRoute(
  path: ExampleScreen.routeName,
  builder: (BuildContext context, GoRouterState state) {
    return const ExampleScreen();
  },
),
```

## Form Field Pattern

When creating form fields, follow this pattern:

```dart
TextField(
  controller: _textController,
  decoration: const InputDecoration(
    labelText: 'Label Text',
    hintText: 'Hint text',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.example),
  ),
  keyboardType: TextInputType.text,
  enabled: !_isLoading,
),
const SizedBox(height: 16),
```

## Error Handling Pattern

When handling errors in UI:

```dart
if (_errorMessage != null)
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Text(
      _errorMessage!,
      style: TextStyle(color: Colors.red.shade800),
    ),
  ),
```

## Button Pattern

When creating buttons:

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _onPressFunction,
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: _isLoading
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('Button Text'),
),
```

## Theming Pattern

When applying custom themes:

```dart
Text(
  "Example Text",
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
    fontFamily: 'NotoSansKR',
  ),
),
```

## Supabase Authentication Pattern

When implementing authentication functionality:

```dart
try {
  final response = await SupabaseService.signInWithEmail(email, password);
  final session = response.session;
  final user = response.user;
  
  if (session == null || user == null) {
    // Handle error
  } else {
    // Handle success
  }
} catch (e) {
  // Handle exception
}
```

## Constants and Configuration

Store configuration values in dedicated files under the config/ directory:

```dart
// Example config file
class ApiConfig {
  static const baseUrl = 'https://example.com/api';
  static const timeout = Duration(seconds: 30);
}
```
