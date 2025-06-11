import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:posle_menya/screens/pin_code_screen.dart';
import 'package:posle_menya/services/secure_storage_service.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoading = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      _biometricAvailable =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      final useBiometrics = await SecureStorageService.getUseBiometrics();
      final hasPin = await SecureStorageService.hasPinCode();

      if (useBiometrics && _biometricAvailable) {
        final authenticated = await _authenticateWithBiometrics();
        if (authenticated && mounted) {
          _navigateToHome();
          return;
        }
      }

      if (hasPin && mounted) {
        _navigateToPinCode();
      } else if (mounted) {
        _navigateToWelcome();
      }
    } catch (e) {
      if (mounted) _navigateToWelcome();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Подтвердите вашу личность для входа',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/selection');
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  void _navigateToPinCode() {
    final onSuccess = () {
      Navigator.of(context).pushReplacementNamed('/selection');
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            PinCodeScreen(isSetup: false, onSuccess: onSuccess),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Не удалось войти',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
      ),
    );
  }
}
