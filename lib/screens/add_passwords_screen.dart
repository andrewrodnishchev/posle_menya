import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class PasswordEntry extends HiveObject {
  @HiveField(0)
  final String service;

  @HiveField(1)
  final String login;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final DateTime createdAt;

  PasswordEntry({
    required this.service,
    required this.login,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'service': service,
      'login': login,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      service: map['service'] as String,
      login: map['login'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class PasswordEntryAdapter extends TypeAdapter<PasswordEntry> {
  @override
  final int typeId = 0;

  @override
  PasswordEntry read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return PasswordEntry.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, PasswordEntry obj) {
    writer.writeMap(obj.toMap());
  }
}

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({super.key});

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  late Box<PasswordEntry> _passwordsBox;
  final List<bool> _passwordVisible = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _passwordsBox = await Hive.openBox<PasswordEntry>('passwords');
    _updateVisibilityList();
    setState(() => _isLoading = false);
  }

  void _updateVisibilityList() {
    _passwordVisible.clear();
    _passwordVisible.addAll(List.filled(_passwordsBox.length, false));
  }

  Future<void> _addEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = PasswordEntry(
        service: _serviceController.text,
        login: _loginController.text,
        password: _passwordController.text,
      );

      await _passwordsBox.add(entry);
      _serviceController.clear();
      _loginController.clear();
      _passwordController.clear();

      _updateVisibilityList();
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {});
      }
    }
  }

  Future<void> _deleteEntry(int index) async {
    await _passwordsBox.deleteAt(index);
    _updateVisibilityList();
    if (mounted) setState(() {});
  }

  Future<void> _deleteAllEntries() async {
    await _passwordsBox.clear();
    _updateVisibilityList();
    if (mounted) setState(() {});
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(76),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Заполните поле' : null,
    );
  }

  void _showAddPasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Добавить пароль'),
            actions: [
              IconButton(icon: const Icon(Icons.check), onPressed: _addEntry),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_serviceController, 'Сервис'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _loginController,
                    'Логин',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Пароль', obscure: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordDetails(int index) {
    final entry = _passwordsBox.getAt(index)!;
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
                entry.service,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Логин', entry.login),
            const SizedBox(height: 12),
            _buildDetailRow('Пароль', entry.password),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Создано',
              '${entry.createdAt.day}.${entry.createdAt.month}.${entry.createdAt.year}',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteEntry(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Удалить'),
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
            color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
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
    _serviceController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _passwordsBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Пароли и логины'),
        actions: [
          if (!_isLoading && _passwordsBox.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить все пароли?'),
                    content: const Text('Это действие нельзя отменить'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteAllEntries();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _showAddPasswordScreen,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _passwordsBox.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(127),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет сохранённых паролей',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(127),
                    ),
                  ),
                ],
              ),
            )
          : ValueListenableBuilder(
              valueListenable: _passwordsBox.listenable(),
              builder: (context, Box<PasswordEntry> box, _) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final entry = box.getAt(index)!;
                    return Card(
                      color: Theme.of(context).cardTheme.color,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          entry.service,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.login,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _passwordVisible[index]
                                        ? entry.password
                                        : '••••••••',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(180),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _passwordVisible[index]
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(127),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible[index] =
                                          !_passwordVisible[index];
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showPasswordDetails(index),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
