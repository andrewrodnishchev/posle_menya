import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posle_menya/error_handler.dart';
import 'package:posle_menya/screens/welcome_screen.dart';
import 'package:posle_menya/screens/selection_screen.dart';
import 'package:posle_menya/screens/add_passwords_screen.dart';
import 'package:posle_menya/screens/add_files_screen.dart';
import 'package:posle_menya/screens/settings_screen.dart';
import 'package:posle_menya/screens/messages_screen.dart';
import 'package:posle_menya/screens/media_screen.dart';
import 'package:posle_menya/screens/recipients_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрация адаптеров
  Hive.registerAdapter(PasswordEntryAdapter());

  // Настройка обработки ошибок
  AppErrorHandler.setup();

  runApp(const PosleMenyaApp());
}

class PosleMenyaApp extends StatelessWidget {
  const PosleMenyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'После меня',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        ErrorWidget.builder = (errorDetails) {
          debugPrint(
            'Widget Error: ${errorDetails.exception}\n${errorDetails.stack}',
          );
          return Scaffold(
            body: Center(
              child: Text(
                'Ошибка: ${errorDetails.exception}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        };
        return child!;
      },
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.deepPurple,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
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
              debugPrint('⚠️ Unknown route: ${settings.name}');
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
            transitionDuration: const Duration(milliseconds: 200),
            reverseTransitionDuration: const Duration(milliseconds: 200),
          );
        } catch (e, st) {
          debugPrint('Route generation error: $e\n$st');
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
