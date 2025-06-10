import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:posle_menya/error_handler.dart';
import 'package:posle_menya/providers/theme_provider.dart';
import 'package:posle_menya/screens/welcome_screen.dart';
import 'package:posle_menya/screens/selection_screen.dart';
import 'package:posle_menya/screens/add_passwords_screen.dart';
import 'package:posle_menya/screens/add_files_screen.dart';
import 'package:posle_menya/screens/settings_screen.dart';
import 'package:posle_menya/screens/messages_screen.dart';
import 'package:posle_menya/screens/media_screen.dart';
import 'package:posle_menya/screens/recipients_screen.dart';
import 'package:posle_menya/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PasswordEntryAdapter());
  AppErrorHandler.setup();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PosleMenyaApp(),
    ),
  );
}

class PosleMenyaApp extends StatelessWidget {
  const PosleMenyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'После меня',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: Colors.deepPurple,
          surface: Colors.grey[100]!,
          surfaceVariant:
              Colors.white, // Replaced background with surfaceVariant
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
          shape: AppStyles.cardShape,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: Colors.deepPurple,
          surface: AppColors.cardBackground,
          surfaceVariant:
              AppColors.background, // Replaced background with surfaceVariant
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
          color: AppColors.cardBackground,
          shape: AppStyles.cardShape,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      themeMode: themeProvider.themeMode,
      onGenerateRoute: (settings) {
        try {
          WidgetBuilder? builder;
          switch (settings.name) {
            case '/':
              builder = (_) => const WelcomeScreen();
              break;
            case '/selection':
              builder = (_) => const SelectionScreen();
              break;
            case '/add_passwords':
              builder = (_) => const PasswordsScreen();
              break;
            case '/add_files':
              builder = (_) => const AddFilesScreen();
              break;
            case '/settings':
              builder = (_) => const SettingsScreen();
              break;
            case '/messages':
              builder = (_) => const MessagesScreen();
              break;
            case '/media':
              builder = (_) => const MediaScreen();
              break;
            case '/recipients':
              builder = (_) => const RecipientsScreen();
              break;
            default:
              builder = (_) => Scaffold(
                appBar: AppBar(title: const Text('Ошибка')),
                body: Center(
                  child: Text('Маршрут "${settings.name}" не найден'),
                ),
              );
          }

          return PageRouteBuilder(
            pageBuilder: (context, _, __) => builder!(context),
            transitionsBuilder: (context, animation, _, child) {
              const begin = Offset(0.0, 0.1);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Ошибка')),
              body: const Center(
                child: Text('Произошла ошибка при открытии страницы'),
              ),
            ),
          );
        }
      },
    );
  }
}
