import 'package:flutter/material.dart';
import 'package:sgm/router.dart';
import 'package:sgm/services/auth_service.dart';
import 'package:sgm/theme/theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service (which initializes Supabase)
  await authService.initialize();
  // await Supabase.initialize(
  //   url: SupabaseConfig.supabaseUrl,
  //   anonKey: SupabaseConfig.supabaseAnonKey,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: MaterialTheme.createThemeData(context),
    );
  }
}
