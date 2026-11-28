import 'package:flutter_test/flutter_test.dart';
import 'package:lab13/models/diary_entry.dart';

void main() {
  test('DiaryEntry JSON test', () {
    const entry = DiaryEntry(
      id: '1',
      photoPath: 'photo.jpg',
      caption: 'Narxoz',
      timestamp: '2026-11-28T12:00:00',
      latitude: 43.238949,
      longitude: 76.889709,
      altitude: 800,
      accuracy: 12.4,
    );

    final restored = DiaryEntry.fromJson(
      entry.toJson(),
    );

    expect(restored.caption, 'Narxoz');
    expect(restored.latitude, 43.238949);
    expect(restored.photoPath, 'photo.jpg');
  });
}