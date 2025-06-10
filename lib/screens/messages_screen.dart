import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _recipientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('saved_messages');
    if (messagesJson != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(
          json.decode(messagesJson).map((x) => Map<String, dynamic>.from(x)),
        );
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_messages', json.encode(_messages));
  }

  void _showMessageEditor({int? index}) {
    if (index != null) {
      final message = _messages[index];
      _titleController.text = message['title'] ?? '';
      _contentController.text = message['content'] ?? '';
      _recipientController.text = message['recipient'] ?? '';
    } else {
      _titleController.clear();
      _contentController.clear();
      _recipientController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    index != null
                        ? 'Редактировать сообщение'
                        : 'Новое сообщение',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Введите заголовок'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      labelText: 'Получатель (email или телефон)',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Укажите получателя'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Текст сообщения',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 5,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Введите текст сообщения'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Отмена',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveMessage(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Сохранить',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMessage(int? index) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final message = {
          'title': _titleController.text,
          'recipient': _recipientController.text,
          'content': _contentController.text,
          'createdAt': DateTime.now().toIso8601String(),
        };

        if (index != null) {
          _messages[index] = message;
        } else {
          _messages.add(message);
        }
      });

      await _saveMessages();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteMessage(int index) async {
    setState(() {
      _messages.removeAt(index);
    });
    await _saveMessages();
  }

  Future<void> _deleteAllMessages() async {
    setState(() {
      _messages.clear();
    });
    await _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить все сообщения?'),
                    content: const Text('Это действие нельзя отменить'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteAllMessages();
                        },
                        child: const Text(
                          'Удалить',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(127),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет сохранённых сообщений',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final createdAt = DateTime.parse(message['createdAt']);

                return Card(
                  color: Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    title: Text(
                      message['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Для: ${message['recipient']}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Создано: ${createdAt.day}.${createdAt.month}.${createdAt.year}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(127),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showMessageEditor(index: index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteMessage(index),
                        ),
                      ],
                    ),
                    onTap: () => _showMessageDetails(message, createdAt),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _showMessageEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMessageDetails(Map<String, dynamic> message, DateTime createdAt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                message['title'],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Получатель', message['recipient']),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Создано',
              '${createdAt.day}.${createdAt.month}.${createdAt.year}',
            ),
            const SizedBox(height: 12),
            Text(
              'Текст сообщения:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message['content'],
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(127),
                      ),
                    ),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
