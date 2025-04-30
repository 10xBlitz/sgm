import 'package:flutter/material.dart';
import 'package:sgm/config/supabase_config.dart';
import 'package:sgm/router.dart';
import 'package:sgm/services/auth_service.dart';
import 'package:sgm/theme/theme.dart';
import 'package:sgm/theme/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(
      context,
      "Noto Sans KR",
      "Noto Sans KR",
    );
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp.router(
      routerConfig: router,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
    );
  }
}
