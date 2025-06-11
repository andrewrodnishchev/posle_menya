import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:posle_menya/services/secure_storage_service.dart';

class PinCodeScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onSuccess;

  const PinCodeScreen({super.key, this.isSetup = false, this.onSuccess});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final List<String> _enteredPin = [];
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _isError = false;
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _maybeShowBiometricModal();
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

  Future<void> _maybeShowBiometricModal() async {
    final useBiometrics = await SecureStorageService.getUseBiometrics();
    final hasPin = await SecureStorageService.hasPinCode();

    if (!widget.isSetup && useBiometrics && hasPin && _biometricSupported) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      await _startBiometricAuth(showDialogOnFail: true);
    }
  }

  Future<void> _startBiometricAuth({bool showDialogOnFail = false}) async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Войдите с помощью отпечатка пальца',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onSuccess?.call();
        Navigator.pushReplacementNamed(context, '/selection');
      } else if (showDialogOnFail && mounted) {
        _showBiometricFailedDialog();
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ошибка биометрии. Попробуйте снова или используйте PIN-код',
            ),
          ),
        );
        if (showDialogOnFail) {
          _showBiometricFailedDialog();
        }
      }
    }
  }

  void _showBiometricFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка входа'),
        content: const Text(
          'Не удалось выполнить биометрическую аутентификацию',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ввести PIN'),
          ),
          ElevatedButton(
            onPressed: () => _startBiometricAuth(showDialogOnFail: true),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildBiometricDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Вход'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fingerprint, size: 64),
          const SizedBox(height: 16),
          const Text('Отсканируйте отпечаток пальца'),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin.add(number);
      _isError = false;
    });
    if (_enteredPin.length == 4) {
      widget.isSetup ? _handleSetupPin() : _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _handleSetupPin() async {
    if (!_isConfirmStep) {
      setState(() {
        _confirmPin = _enteredPin.join();
        _enteredPin.clear();
        _isConfirmStep = true;
      });
    } else {
      if (_confirmPin == _enteredPin.join()) {
        await SecureStorageService.setPinCode(_confirmPin);
        widget.onSuccess?.call();
        if (mounted && widget.onSuccess == null) {
          Navigator.pushReplacementNamed(context, '/selection');
        }
      } else {
        setState(() {
          _isError = true;
          _enteredPin.clear();
          _confirmPin = '';
          _isConfirmStep = false;
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    final storedPin = await SecureStorageService.getPinCode();
    if (storedPin == _enteredPin.join()) {
      widget.onSuccess?.call();
      if (mounted && widget.onSuccess == null) {
        Navigator.pushReplacementNamed(context, '/selection');
      }
    } else {
      setState(() {
        _isError = true;
        _enteredPin.clear();
      });
    }
  }

  Widget _buildPinIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _enteredPin.length
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: Border.all(
              color: _isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBiometricButton(),
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: _onBackspacePressed,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    if (!_biometricSupported || widget.isSetup) {
      return const SizedBox(width: 72, height: 72);
    }

    return FutureBuilder<bool>(
      future: SecureStorageService.getUseBiometrics(),
      builder: (context, snapshot) {
        final show = snapshot.data == true;
        if (!show) return const SizedBox(width: 72, height: 72);

        return InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => _startBiometricAuth(),
          child: Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.fingerprint,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              widget.isSetup
                  ? _isConfirmStep
                        ? 'Подтвердите PIN-код'
                        : 'Установите новый PIN-код'
                  : 'Введите PIN-код',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildPinIndicator(),
            if (_isError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  widget.isSetup ? 'PIN-коды не совпадают' : 'Неверный PIN-код',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const Spacer(flex: 3),
            _buildKeypad(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
