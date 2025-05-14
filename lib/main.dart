import 'package:flutter/material.dart';
import 'package:sgm/router.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/theme/theme.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service (which initializes Supabase)
  await AuthService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: MaterialTheme.createThemeData(context),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
