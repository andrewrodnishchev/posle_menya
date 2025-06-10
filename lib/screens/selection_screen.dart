import 'package:flutter/material.dart';
import 'package:posle_menya/error_handler.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Выберите, что сохранить',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildOption(
            context,
            icon: Icons.lock_outline,
            title: 'Пароли и логины',
            subtitle: 'Доступы к важным аккаунтам',
            route: '/add_passwords',
          ),
          _buildOption(
            context,
            icon: Icons.email_outlined,
            title: 'Письма и сообщения',
            subtitle: 'Тексты, которые вы хотите передать',
            route: '/messages',
          ),
          _buildOption(
            context,
            icon: Icons.video_library_outlined,
            title: 'Видео и аудио',
            subtitle: 'Ваши послания или важные записи',
            route: '/media',
          ),
          _buildOption(
            context,
            icon: Icons.people_outline,
            title: 'Контакты получателей',
            subtitle: 'Кому отправить ваши данные',
            route: '/recipients',
          ),
          _buildOption(
            context,
            icon: Icons.settings_outlined,
            title: 'Настройки',
            subtitle: 'Способы активации и безопасности',
            route: '/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            await Navigator.of(context).pushNamed(route);
          } catch (e) {
            AppErrorHandler.handleNavigationError(context, e);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDark
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    ],
                  ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
