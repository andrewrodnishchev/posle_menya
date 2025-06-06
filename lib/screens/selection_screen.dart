import 'package:flutter/material.dart';
import 'package:posle_menya/error_handler.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Выберите, что сохранить',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
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
    return GestureDetector(
      onTap: () async {
        try {
          await Navigator.of(context).pushNamed(route);
        } catch (e) {
          AppErrorHandler.handleNavigationError(context, e);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurpleAccent, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
