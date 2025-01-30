class AlarmModel {
  double volume;
  String? ringtonePath;
  static const String RINGTONE_PATH_KEY = 'ringtone_path';
  static const String VOLUME_KEY = 'volume_level';

  AlarmModel({
    this.volume = 0.5,
    this.ringtonePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'volume': volume,
      'ringtonePath': ringtonePath,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      volume: json['volume'] ?? 0.5,
      ringtonePath: json['ringtonePath'],
    );
  }
}