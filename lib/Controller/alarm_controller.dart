import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../Model/alarm_model.dart';

class AlarmController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final AlarmModel alarmModel;

  AlarmController(): alarmModel = AlarmModel();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    alarmModel.ringtonePath = prefs.getString(AlarmModel.RINGTONE_PATH_KEY);
    alarmModel.volume = prefs.getDouble(AlarmModel.VOLUME_KEY) ?? 0.5;
    await audioPlayer.setVolume(alarmModel.volume);
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (alarmModel.ringtonePath != null) {
      await prefs.setString(AlarmModel.RINGTONE_PATH_KEY, alarmModel.ringtonePath!);
    }
    await prefs.setDouble(AlarmModel.VOLUME_KEY, alarmModel.volume);
  }

  Future<bool> pickRingtone() async {
    try {
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> permissions = await [
          Permission.storage,
          Permission.manageExternalStorage,
          Permission.mediaLibrary,
        ].request();

        if (!permissions.values.any((status) => status.isGranted)) {
          await openAppSettings();
          return false;
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        alarmModel.ringtonePath = result.files.single.path;
        await saveSettings();
        return true;
      }
      return false;
    } catch (e) {
      print('Audio selection error: $e');
      return false;
    }
  }

  Future<bool> playRingtone() async {
    if (alarmModel.ringtonePath != null) {
      try {
        await audioPlayer.setVolume(alarmModel.volume);
        Source audioSource = DeviceFileSource(alarmModel.ringtonePath!);
        await audioPlayer.play(audioSource);
        return true;
      } catch (e) {
        print('Audio playback error: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> stopRingtone() async {
    await audioPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    alarmModel.volume = volume;
    await audioPlayer.setVolume(volume);
    await saveSettings();
  }

  void dispose() {
    audioPlayer.dispose();
  }

  String getFileName() {
    return alarmModel.ringtonePath != null
        ? alarmModel.ringtonePath!.split('/').last
        : 'Select Ringtone';
  }
}