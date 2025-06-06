import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, String>> messages = [];

  void _showMessageEditor({Map<String, String>? message}) {
    final titleController = TextEditingController(text: message?['title']);
    final contentController = TextEditingController(text: message?['content']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          message == null ? 'Новое сообщение' : 'Редактировать',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Содержание',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                setState(() {
                  if (message == null) {
                    messages.add({
                      'title': titleController.text,
                      'content': contentController.text,
                      'preview': contentController.text.length > 50
                          ? '${contentController.text.substring(0, 50)}...'
                          : contentController.text,
                      'date': DateTime.now().toString(),
                    });
                  } else {
                    final index = messages.indexOf(message);
                    messages[index] = {
                      'title': titleController.text,
                      'content': contentController.text,
                      'preview': contentController.text.length > 50
                          ? '${contentController.text.substring(0, 50)}...'
                          : contentController.text,
                      'date': message['date'] ?? DateTime.now().toString(),
                    };
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Письма и сообщения'),
        backgroundColor: Colors.black,
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  messages.clear();
                });
              },
            ),
        ],
      ),
      body: messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.email_outlined, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Вы ещё не добавили ни одного письма',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(
                    msg['title'] ?? 'Без заголовка',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['preview'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['date'] != null
                            ? 'Создано: ${DateTime.parse(msg['date']!).toLocal()}'
                            : '',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () => _showMessageEditor(message: msg),
                  onLongPress: () {
                    setState(() {
                      messages.removeAt(index);
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => _showMessageEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
