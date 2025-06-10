import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posle_menya/constants.dart';
import 'package:posle_menya/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTimeOption = 1;
  bool _biometricAuthEnabled = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Безопасность',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Сменить мастер-пароль',
            onTap: () => _showPasswordChangeDialog(context),
          ),
          _buildSettingItem(
            icon: Icons.fingerprint,
            title: 'Биометрическая аутентификация',
            trailing: Switch(
              value: _biometricAuthEnabled,
              onChanged: (value) =>
                  setState(() => _biometricAuthEnabled = value),
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Активация отправки',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.timer_outlined,
            title: 'Отправка по времени',
            onTap: () => _showTimeSettingsDialog(context),
          ),
          _buildSettingItem(
            icon: Icons.location_on_outlined,
            title: 'Гео-активация',
            onTap: () => _showLocationSettings(context),
          ),
          _buildSettingItem(
            icon: Icons.sensor_door_outlined,
            title: 'Активация при отсутствии',
            onTap: () => _showInactivitySettings(context),
          ),

          const SizedBox(height: 24),
          Text(
            'Внешний вид',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: 'Тёмная тема',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'О приложении',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'Версия 1.0.0',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Политика конфиденциальности',
            onTap: () => _showPrivacyPolicy(context),
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Помощь и поддержка',
            onTap: () => _showHelpScreen(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: AppStyles.cardShape,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
            ),
        onTap: onTap,
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Смена пароля'),
        backgroundColor: AppColors.cardBackground,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Текущий пароль',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Подтвердите пароль',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Пароль успешно изменён'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showTimeSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Настройка времени'),
            backgroundColor: AppColors.cardBackground,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  title: const Text(
                    'Через 1 месяц',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 1,
                  groupValue: _selectedTimeOption,
                  onChanged: (value) =>
                      setState(() => _selectedTimeOption = value!),
                  activeColor: AppColors.primary,
                ),
                RadioListTile<int>(
                  title: const Text(
                    'Через 3 месяца',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 2,
                  groupValue: _selectedTimeOption,
                  onChanged: (value) =>
                      setState(() => _selectedTimeOption = value!),
                  activeColor: AppColors.primary,
                ),
                RadioListTile<int>(
                  title: const Text(
                    'Через 6 месяцев',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 3,
                  groupValue: _selectedTimeOption,
                  onChanged: (value) =>
                      setState(() => _selectedTimeOption = value!),
                  activeColor: AppColors.primary,
                ),
                RadioListTile<int>(
                  title: const Text(
                    'Кастомный период',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 4,
                  groupValue: _selectedTimeOption,
                  onChanged: (value) =>
                      setState(() => _selectedTimeOption = value!),
                  activeColor: AppColors.primary,
                ),
                if (_selectedTimeOption == 4) ...[
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Количество дней',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Настройки сохранены'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLocationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Гео-активация'),
        backgroundColor: AppColors.cardBackground,
        content: const Text(
          'Приложение отправит данные, если вы долгое время не посещали указанное место',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Понятно',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showInactivitySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Активация при отсутствии'),
        backgroundColor: AppColors.cardBackground,
        content: const Text(
          'Данные будут отправлены, если вы не открывали приложение в течение указанного времени',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: Реализовать экран с политикой конфиденциальности
  }

  void _showHelpScreen(BuildContext context) {
    // TODO: Реализовать экран помощи
  }
}
