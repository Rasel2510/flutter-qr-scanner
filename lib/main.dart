import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFFFF3E4),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFFF3E4),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(
    // Wrap the entire app in ProviderScope to enable Riverpod
    const ProviderScope(
      child: QRCraftApp(),
    ),
  );
}

class QRCraftApp extends StatelessWidget {
  const QRCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRcraft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

