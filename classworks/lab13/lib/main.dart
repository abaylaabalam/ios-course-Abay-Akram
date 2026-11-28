import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/diary_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String directoryPath = '';

  if (!kIsWeb) {
    final directory =
        await getApplicationDocumentsDirectory();

    directoryPath = directory.path;
  }

  runApp(MyApp(directoryPath: directoryPath));
}

class MyApp extends StatelessWidget {
  final String directoryPath;

  const MyApp({
    super.key,
    required this.directoryPath,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DALA DIARY',
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: DiaryScreen(
        directoryPath: directoryPath,
      ),
    );
  }
}