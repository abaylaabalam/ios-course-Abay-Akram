import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_item.dart';

class NotesScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String initialUsername;
  final List<NoteItem> initialNotes;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const NotesScreen({
    super.key,
    required this.prefs,
    required this.initialUsername,
    required this.initialNotes,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late String username;
  late List<NoteItem> notes;

  late TextEditingController nameController;
  final TextEditingController noteController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    username = widget.initialUsername;
    notes = List.from(widget.initialNotes);

    nameController = TextEditingController(
      text: username,
    );
  }

  Future<void> saveUsername() async {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    setState(() {
      username = name;
    });

    await widget.prefs.setString(
      'user_display_name',
      username,
    );
  }

  Future<void> saveNotes() async {
    final data = notes.map((note) {
      return note.toJson();
    }).toList();

    final json = jsonEncode(data);

    await widget.prefs.setString(
      'notes_list',
      json,
    );
  }

  Future<void> addNote() async {
    final title = noteController.text.trim();

    if (title.isEmpty) return;

    final now = DateTime.now();

    final note = NoteItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      dateText: '${now.day}.${now.month}.${now.year}',
    );

    setState(() {
      notes.insert(0, note);
      noteController.clear();
    });

    await saveNotes();
  }

  Future<void> toggleNote(NoteItem note) async {
    setState(() {
      note.isCompleted = !note.isCompleted;
    });

    await saveNotes();
  }

  Future<void> deleteNote(String id) async {
    setState(() {
      notes.removeWhere((note) => note.id == id);
    });

    await saveNotes();
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = notes.where((note) {
      return note.isCompleted;
    }).length;

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DALA.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              widget.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              color: colors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сәлем, $username!',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Жеке жазбалар',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Баптаулар',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Қараңғы режим'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: widget.isDark,
              onChanged: widget.onThemeChanged,
            ),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Пайдаланушы аты'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Атыңызды енгізіңіз',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: saveUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size(70, 55),
                  ),
                  child: const Text('Сақтау'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Менің жазбаларым',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${notes.length} жазба / $completedCount орындалды',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              onSubmitted: (value) {
                addNote();
              },
              decoration: const InputDecoration(
                hintText: 'Жаңа жазба...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: addNote,
                icon: const Icon(Icons.add),
                label: const Text('Жазба қосу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (notes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 35),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Жазбалар жоқ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              ...notes.map((note) {
                return Column(
                  key: ValueKey(note.id),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: note.isCompleted,
                        onChanged: (value) {
                          toggleNote(note);
                        },
                      ),
                      title: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 15,
                          decoration: note.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        note.dateText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          deleteNote(note.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}