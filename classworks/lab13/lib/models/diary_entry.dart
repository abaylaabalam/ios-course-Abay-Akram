class DiaryEntry {
  final String id;
  final String photoPath;
  final String caption;
  final String timestamp;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;

  const DiaryEntry({
    required this.id,
    required this.photoPath,
    required this.caption,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoPath': photoPath,
      'caption': caption,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      photoPath: json['photoPath'] as String,
      caption: json['caption'] as String,
      timestamp: json['timestamp'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }
}