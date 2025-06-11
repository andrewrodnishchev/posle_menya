import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:posle_menya/screens/pin_code_screen.dart';
import 'package:posle_menya/services/secure_storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isLoading = false;
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();

      setState(() {
        _biometricSupported = canCheck && isSupported && available.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Biometric support check error: $e');
      setState(() => _biometricSupported = false);
    }
  }

  Future<bool> _tryBiometricAuth() async {
    if (!_biometricSupported) return false;

    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Войдите с помощью отпечатка пальца',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка биометрии: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  Future<void> _startAuthFlow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final hasPin = await SecureStorageService.hasPinCode();
      final usePin = await SecureStorageService.getUsePin();
      final useBiometrics = await SecureStorageService.getUseBiometrics();

      if (!usePin) {
        if (mounted) Navigator.pushReplacementNamed(context, '/selection');
        return;
      }

      if (hasPin) {
        if (useBiometrics && _biometricSupported) {
          final success = await _tryBiometricAuth();
          if (success && mounted) {
            Navigator.pushReplacementNamed(context, '/selection');
            return;
          }
        }

        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PinCodeScreen(
                isSetup: false,
                onSuccess: () =>
                    Navigator.pushReplacementNamed(context, '/selection'),
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinCodeScreen(
              isSetup: true,
              onSuccess: () =>
                  Navigator.pushReplacementNamed(context, '/selection'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startAuthFlow,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  'После меня',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Чтобы главное не осталось несказанным.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Тапни в любое место, чтобы начать',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
