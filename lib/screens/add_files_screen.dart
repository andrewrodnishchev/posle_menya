import 'package:flutter/material.dart';

class AddFilesScreen extends StatelessWidget {
  const AddFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить файлы'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: const Center(
        child: Text(
          'Здесь будет функционал добавления файлов',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
