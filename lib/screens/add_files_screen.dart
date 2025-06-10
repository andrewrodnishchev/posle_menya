import 'package:flutter/material.dart';

class AddFilesScreen extends StatelessWidget {
  const AddFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить файлы'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Text(
          'Здесь будет функционал добавления файлов',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
