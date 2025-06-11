import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:posle_menya/screens/add_passwords_screen.dart';
import 'package:posle_menya/screens/auth_gate_screen.dart';
import 'package:posle_menya/screens/media_screen.dart';
import 'package:posle_menya/screens/messages_screen.dart';
import 'package:posle_menya/screens/pin_code_screen.dart';
import 'package:posle_menya/screens/recipients_screen.dart';
import 'package:posle_menya/screens/selection_screen.dart';
import 'package:posle_menya/screens/settings_screen.dart';
import 'package:posle_menya/screens/welcome_screen.dart';
import 'package:posle_menya/providers/theme_provider.dart';
import 'package:posle_menya/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Инициализация Hive
  Hive.registerAdapter(PasswordEntryAdapter()); // Регистрация адаптера

  AppErrorHandler.setup();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'После меня',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6200EE),
          secondary: Colors.deepPurple,
          surface: Colors.grey[100]!,
          surfaceContainerHighest: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6200EE),
          secondary: Colors.deepPurple,
          surface: const Color(0xFF1E1E1E),
          surfaceContainerHighest: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthGateScreen(),
        '/pin': (context) => const PinCodeScreen(),
        '/selection': (context) => const SelectionScreen(),
        '/add_passwords': (context) => const PasswordsScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/media': (context) => const MediaScreen(),
        '/recipients': (context) => const RecipientsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Страница ${settings.name} не найдена')),
          ),
        );
      },
    );
  }
}
