import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  configLoading();
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
      builder: (EasyLoading.init()),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorColor = Colors.red
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.green
    ..backgroundColor = Colors.green
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue
    ..userInteractions = true
    ..dismissOnTap = false;
}
