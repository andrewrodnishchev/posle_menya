import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:posle_menya/constants.dart';

class AppErrorHandler {
  static void setup() {
    FlutterError.onError = (details) {
      _logError('Flutter Error', details.exception, details.stack!);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  static void _logError(String message, dynamic error, StackTrace stackTrace) {
    debugPrint('🚨 $message: $error\n$stackTrace');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: error.toString());
    }
  }

  static void handleNavigationError(BuildContext context, dynamic error) {
    _logError('Navigation Error', error, StackTrace.current);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ошибка при переходе'),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Подробности',
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Ошибка навигации'),
                content: SingleChildScrollView(
                  child: Text(
                    '${error.toString()}\n\nПопробуйте перезапустить приложение.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                backgroundColor: AppColors.cardBackground,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void handleFileError(
    BuildContext context,
    dynamic error, [
    StackTrace? stack,
  ]) {
    _logError('File Error', error, stack ?? StackTrace.current);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ошибка работы с файлом'),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Повторить',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Добавить логику повторной попытки
          },
        ),
      ),
    );
  }

  static void handleAuthError(BuildContext context, dynamic error) {
    _logError('Auth Error', error, StackTrace.current);

    String errorMessage = 'Ошибка аутентификации';
    if (error.toString().contains('weak-password')) {
      errorMessage = 'Пароль слишком слабый';
    } else if (error.toString().contains('wrong-password')) {
      errorMessage = 'Неверный пароль';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ошибка аутентификации'),
        content: Text(errorMessage),
        backgroundColor: AppColors.cardBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  static void handleNetworkError(BuildContext context) {
    _logError('Network Error', 'No internet connection', StackTrace.current);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нет подключения к интернету'),
        backgroundColor: AppColors.errorColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: AppColors.cardBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
