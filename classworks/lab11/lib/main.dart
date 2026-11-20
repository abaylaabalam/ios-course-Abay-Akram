import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/note_item.dart';
import 'screens/notes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final isDark =
      prefs.getBool('app_theme_dark_mode') ?? false;

  final username =
      prefs.getString('user_display_name') ?? 'Guest User';

  final savedNotes = prefs.getString('notes_list');

  List<NoteItem> notes = [];

  if (savedNotes != null) {
    try {
      final data = jsonDecode(savedNotes) as List;

      notes = data.map((item) {
        return NoteItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } catch (e) {
      notes = [];
    }
  }

  runApp(
    MyApp(
      prefs: prefs,
      initialDark: isDark,
      username: username,
      notes: notes,
    ),
  );
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool initialDark;
  final String username;
  final List<NoteItem> notes;

  const MyApp({
    super.key,
    required this.prefs,
    required this.initialDark,
    required this.username,
    required this.notes,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.initialDark;
  }

  Future<void> changeTheme(bool value) async {
    setState(() {
      isDark = value;
    });

    await widget.prefs.setBool(
      'app_theme_dark_mode',
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DALA NOTES',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: NotesScreen(
        prefs: widget.prefs,
        initialUsername: widget.username,
        initialNotes: widget.notes,
        isDark: isDark,
        onThemeChanged: changeTheme,
      ),
    );
  }
}