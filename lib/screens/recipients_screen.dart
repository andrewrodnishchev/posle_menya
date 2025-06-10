import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  List<Map<String, String>> _recipients = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadRecipients();
  }

  Future<void> _loadRecipients() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipientsJson = prefs.getString('recipients');
    if (recipientsJson != null) {
      setState(() {
        _recipients = List<Map<String, String>>.from(
          json.decode(recipientsJson).map((x) => Map<String, String>.from(x)),
        );
      });
    }
  }

  Future<void> _saveRecipients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recipients', json.encode(_recipients));
  }

  void _saveRecipient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final recipient = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'notes': _notesController.text,
        };

        if (_editingIndex != null) {
          _recipients[_editingIndex!] = recipient;
        } else {
          _recipients.add(recipient);
        }

        _clearFields();
        _editingIndex = null;
      });
      await _saveRecipients();
      Navigator.pop(context);
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _notesController.clear();
  }

  void _showEditDialog([int? index]) {
    _editingIndex = index;

    if (index != null) {
      final recipient = _recipients[index];
      _nameController.text = recipient['name']!;
      _emailController.text = recipient['email']!;
      _phoneController.text = recipient['phone']!;
      _addressController.text = recipient['address']!;
      _notesController.text = recipient['notes']!;
    } else {
      _clearFields();
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
                    _editingIndex != null
                        ? 'Редактировать получателя'
                        : 'Добавить получателя',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'ФИО получателя',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ФИО получателя';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      } else if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Телефон',
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
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите телефон';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Адрес',
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
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Примечания',
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
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _clearFields();
                            _editingIndex = null;
                            Navigator.pop(context);
                          },
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
                          onPressed: _saveRecipient,
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
                            _editingIndex != null ? 'Обновить' : 'Сохранить',
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

  Future<void> _deleteRecipient(int index) async {
    setState(() {
      _recipients.removeAt(index);
    });
    await _saveRecipients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Получатели')),
      body: _recipients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(127),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Добавьте получателей для отправки данных',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipients.length,
              itemBuilder: (context, index) {
                final recipient = _recipients[index];
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
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    title: Text(
                      recipient['name']!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipient['email']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  recipient['email']!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (recipient['phone']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  recipient['phone']!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (recipient['address']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recipient['address']!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(180),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (recipient['notes']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recipient['notes']!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(180),
                                    ),
                                  ),
                                ),
                              ],
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
                          onPressed: () => _showEditDialog(index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteRecipient(index),
                        ),
                      ],
                    ),
                    onTap: () => _showEditDialog(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
