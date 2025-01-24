import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const AlarmApp());
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1B1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key);

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  double _alarmVolume = 0.5;
  String? _selectedRingtonePath;
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _audioPlayerState = PlayerState.stopped;

  Future<void> _pickRingtone() async {
    try {
      // Request multiple permissions for Android
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> permissions = await [
          Permission.storage,
          Permission.manageExternalStorage,
          Permission.mediaLibrary,
        ].request();

        bool isGranted = permissions.values.any((status) => status.isGranted);

        if (!isGranted) {
          _showSnackBar('Storage permissions are required');
          await openAppSettings();
          return;
        }
      }

      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedRingtonePath = result.files.single.path;
        });
        _showSnackBar('Audio selected: ${_getFileName()}');
      } else {
        _showSnackBar('No audio file selected');
      }
    } catch (e) {
      print('Audio selection error: $e');
      _showSnackBar('Error selecting audio: $e');
    }
  }

  Future<void> _playRingtone() async {
    if (_selectedRingtonePath != null) {
      try {
        await _audioPlayer.setVolume(_alarmVolume);
        Source audioSource = DeviceFileSource(_selectedRingtonePath!);
        await _audioPlayer.play(audioSource);
        
        _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
          setState(() {
            _audioPlayerState = state;
          });
        });

        _showSnackBar('Playing: ${_getFileName()}');
      } catch (e) {
        print('Audio playback error: $e');
        _showSnackBar('Error playing audio: $e');
      }
    } else {
      _showSnackBar('Please select an audio file first');
    }
  }

  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
    setState(() {
      _audioPlayerState = PlayerState.stopped;
    });
    _showSnackBar('Audio stopped');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getFileName() {
    return _selectedRingtonePath != null
        ? _selectedRingtonePath!.split('/').last
        : 'Select Ringtone';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Text(
            'Fraud Alarm',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.5),
                      Colors.blue.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/AlarmPic.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audio Track',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            _getFileName(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickRingtone,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alarm sound',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Volume',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Slider(
            value: _alarmVolume,
            onChanged: (value) {
              setState(() {
                _alarmVolume = value;
                _audioPlayer.setVolume(value);
              });
            },
            activeColor: Colors.green,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _playRingtone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow),
                    const SizedBox(width: 5),
                    Text(_audioPlayerState == PlayerState.playing ? 'Playing' : 'Play'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _stopRingtone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stop),
                    SizedBox(width: 5),
                    Text('Stop'),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.person_outline, color: Colors.white),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.alarm, color: Colors.white),
                ),
                const Icon(Icons.settings_outlined, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
