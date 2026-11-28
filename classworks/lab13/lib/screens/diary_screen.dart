import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';
import 'camera_screen.dart';

class DiaryScreen extends StatefulWidget {
  final String directoryPath;

  const DiaryScreen({
    super.key,
    required this.directoryPath,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final picker = ImagePicker();
  final captionController = TextEditingController();

  XFile? selectedPhoto;
  Uint8List? photoBytes;
  Position? position;
  DateTime? photoTime;

  bool isLoading = true;
  bool isLocating = false;
  bool isPicking = false;
  bool isSaving = false;

  List<DiaryEntry> entries = [];

  bool get busy =>
      isLoading || isLocating || isPicking || isSaving;

  File get diaryFile =>
      File('${widget.directoryPath}/diary.json');

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  void showMessage(
    String message, {
    SnackBarAction? action,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  String formatDate(DateTime date) {
    String two(int value) =>
        value.toString().padLeft(2, '0');

    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }

  Future<void> loadEntries() async {
    try {
      String? savedData;

      if (kIsWeb) {
        final prefs =
            await SharedPreferences.getInstance();

        savedData = prefs.getString('diary_entries');
      } else {
        if (await diaryFile.exists()) {
          savedData = await diaryFile.readAsString();
        }
      }

      if (savedData != null) {
        final data = jsonDecode(savedData) as List;

        final loadedEntries = data.map((item) {
          return DiaryEntry.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
        }).toList();

        if (!mounted) return;

        setState(() {
          entries = loadedEntries;
        });
      }

      if (!kIsWeb && Platform.isAndroid) {
        final lostData = await picker.retrieveLostData();
        final files = lostData.files;

        if (files != null && files.isNotEmpty && mounted) {
          setState(() {
            selectedPhoto = files.first;
            photoTime = DateTime.now();
          });
        }
      }
    } catch (e) {
      showMessage('Жазбаларды жүктеу мүмкін болмады');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (busy) return;

    setState(() {
      isPicking = true;
    });

    try {
      XFile? photo;

      if (kIsWeb && source == ImageSource.camera) {
        photo = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(
            builder: (context) => const CameraScreen(),
          ),
        );
      } else {
        if (!kIsWeb && source == ImageSource.camera) {
          final permission =
              await Permission.camera.request();

          if (!permission.isGranted) {
            showMessage(
              'Камераға рұқсат берілмеген',
              action: permission.isPermanentlyDenied ||
                      permission.isRestricted
                  ? SnackBarAction(
                      label: 'Баптаулар',
                      onPressed: () {
                        openAppSettings();
                      },
                    )
                  : null,
            );

            return;
          }
        }

        photo = await picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1080,
        );
      }

      if (photo == null || !mounted) return;

      final bytes =
          kIsWeb ? await photo.readAsBytes() : null;

      if (!mounted) return;

      setState(() {
        selectedPhoto = photo;
        photoBytes = bytes;
        photoTime = DateTime.now();
        position = null;
      });
    } catch (e) {
      showMessage('Фотоны алу мүмкін болмады');
    } finally {
      if (mounted) {
        setState(() {
          isPicking = false;
        });
      }
    }
  }

  Future<void> fetchLocation() async {
    if (busy) return;

    setState(() {
      isLocating = true;
      position = null;
    });

    try {
      if (!kIsWeb) {
        final enabled =
            await Geolocator.isLocationServiceEnabled();

        if (!enabled) {
          showMessage(
            'GPS өшірулі',
            action: SnackBarAction(
              label: 'Қосу',
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
          );

          return;
        }

        LocationPermission permission =
            await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission =
              await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          showMessage('GPS рұқсаты берілмеді');
          return;
        }

        if (permission ==
            LocationPermission.deniedForever) {
          showMessage(
            'GPS рұқсатын баптаулардан қосыңыз',
            action: SnackBarAction(
              label: 'Баптаулар',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          );

          return;
        }

        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          showMessage('GPS рұқсаты қолжетімсіз');
          return;
        }
      }

      final result = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 20),
      );

      if (!mounted) return;

      setState(() {
        position = result;
      });
    } catch (e) {
      showMessage(
        kIsWeb
            ? 'Браузердегі орналасқан жер рұқсатын тексеріңіз'
            : 'GPS координаттарын алу мүмкін болмады',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLocating = false;
        });
      }
    }
  }

  Future<void> saveEntry() async {
    if (busy) return;

    final photo = selectedPhoto;
    final gps = position;
    final caption = captionController.text.trim();

    if (photo == null) {
      showMessage('Алдымен фото таңдаңыз');
      return;
    }

    if (gps == null) {
      showMessage('Алдымен GPS координаттарын алыңыз');
      return;
    }

    if (caption.isEmpty) {
      showMessage('Сипаттама жазыңыз');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final id =
          DateTime.now().microsecondsSinceEpoch.toString();

      String savedPhoto;

      if (kIsWeb) {
        final bytes =
            photoBytes ?? await photo.readAsBytes();

        savedPhoto = base64Encode(bytes);
      } else {
        final extension = photo.name.contains('.')
            ? photo.name.split('.').last
            : 'jpg';

        savedPhoto = 'photo_$id.$extension';

        await File(photo.path).copy(
          '${widget.directoryPath}/$savedPhoto',
        );
      }

      final entry = DiaryEntry(
        id: id,
        photoPath: savedPhoto,
        caption: caption,
        timestamp: (photoTime ?? DateTime.now())
            .toIso8601String(),
        latitude: gps.latitude,
        longitude: gps.longitude,
        altitude: gps.altitude,
        accuracy: gps.accuracy,
      );

      final updatedEntries = [entry, ...entries];

      final data = jsonEncode(
        updatedEntries.map((item) {
          return item.toJson();
        }).toList(),
      );

      if (kIsWeb) {
        final prefs =
            await SharedPreferences.getInstance();

        final saved = await prefs.setString(
          'diary_entries',
          data,
        );

        if (!saved) {
          throw Exception('Storage error');
        }
      } else {
        final tempFile = File(
          '${widget.directoryPath}/diary_temp.json',
        );

        await tempFile.writeAsString(data, flush: true);
        await tempFile.rename(diaryFile.path);
      }

      if (!mounted) return;

      setState(() {
        entries = updatedEntries;
        selectedPhoto = null;
        photoBytes = null;
        position = null;
        photoTime = null;
        captionController.clear();
      });

      showMessage('Жазба сақталды');
    } catch (e) {
      showMessage(
        'Сақтау мүмкін болмады. Бос жадты тексеріңіз',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget photoPreview() {
    Widget child;

    if (selectedPhoto == null) {
      child = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text('Фото таңдалмаған'),
        ],
      );
    } else if (kIsWeb) {
      child = Image.memory(
        photoBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_outlined);
        },
      );
    } else {
      child = Image.file(
        File(selectedPhoto!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_outlined);
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 250,
        width: double.infinity,
        color: const Color(0xFFF0F0F0),
        child: child,
      ),
    );
  }

  Widget entryImage(DiaryEntry entry) {
    if (kIsWeb) {
      try {
        return Image.memory(
          base64Decode(entry.photoPath),
          width: 85,
          height: 95,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image_outlined);
          },
        );
      } catch (e) {
        return const SizedBox(
          width: 85,
          height: 95,
          child: Icon(Icons.broken_image_outlined),
        );
      }
    }

    return Image.file(
      File('${widget.directoryPath}/${entry.photoPath}'),
      width: 85,
      height: 95,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image_outlined);
      },
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget diaryList() {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text(
            'Күнделік әзірге бос',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 24);
      },
      itemBuilder: (context, index) {
        final entry = entries[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: entryImage(entry),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.caption,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.latitude.toStringAsFixed(6)}°, '
                    '${entry.longitude.toStringAsFixed(6)}°',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Дәлдігі: ± ${entry.accuracy.toStringAsFixed(1)} м',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDate(
                      DateTime.parse(entry.timestamp),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gps = position;

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
          Center(
            child: Text('${entries.length} жазба'),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Фото күнделік',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Естеліктер мен орналасқан жерлер',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 22),
                      photoPreview(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () {
                                      pickPhoto(
                                        ImageSource.camera,
                                      );
                                    },
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                              ),
                              label: const Text('Камера'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () {
                                      pickPhoto(
                                        ImageSource.gallery,
                                      );
                                    },
                              icon: const Icon(
                                Icons.photo_library_outlined,
                              ),
                              label: const Text('Галерея'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Орналасқан жер',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      infoRow(
                        'Ендік (Latitude)',
                        gps == null
                            ? '—'
                            : gps.latitude.toStringAsFixed(6),
                      ),
                      infoRow(
                        'Бойлық (Longitude)',
                        gps == null
                            ? '—'
                            : gps.longitude.toStringAsFixed(6),
                      ),
                      infoRow(
                        'Биіктік (Altitude)',
                        gps == null
                            ? '—'
                            : '${gps.altitude.toStringAsFixed(1)} м',
                      ),
                      infoRow(
                        'GPS дәлдігі',
                        gps == null
                            ? '—'
                            : '± ${gps.accuracy.toStringAsFixed(1)} м',
                      ),
                      infoRow(
                        'Уақыт',
                        photoTime == null
                            ? '—'
                            : formatDate(photoTime!),
                      ),
                      const SizedBox(height: 16),
                      if (isLocating)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: busy
                              ? null
                              : fetchLocation,
                          icon: const Icon(
                            Icons.location_on_outlined,
                          ),
                          label: const Text(
                            'GPS координаттарын алу',
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        'Сипаттама',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: captionController,
                        enabled: !isSaving,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Фото туралы жазыңыз...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: busy ? null : saveEntry,
                          icon: const Icon(
                            Icons.save_outlined,
                          ),
                          label: Text(
                            isSaving
                                ? 'Сақталуда...'
                                : 'Күнделікке сақтау',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Менің жазбаларым',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      diaryList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}