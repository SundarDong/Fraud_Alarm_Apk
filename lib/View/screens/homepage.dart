import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../Controller/alarm_controller.dart';

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key);

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  final AlarmController _controller = AlarmController();
  PlayerState _audioPlayerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _controller.audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  Future<void> _loadSettings() async {
    await _controller.loadSettings();
    setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Fraud Alarm',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAlarmImage() {
    return Stack(
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
    );
  }

  Widget _buildAudioSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                      _controller.getFileName(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  bool success = await _controller.pickRingtone();
                  if (success) {
                    _showSnackBar('Audio selected and saved: ${_controller.getFileName()}');
                    setState(() {});
                  } else {
                    _showSnackBar('No audio file selected');
                  }
                },
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
    );
  }

  Widget _buildVolumeControl() {
    return Column(
      children: [
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
          value: _controller.alarmModel.volume,
          onChanged: (value) async {
            await _controller.setVolume(value);
            setState(() {});
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            bool success = await _controller.playRingtone();
            if (success) {
              _showSnackBar('Playing: ${_controller.getFileName()}');
            } else {
              _showSnackBar('Please select an audio file first');
            }
          },
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
          onPressed: () async {
            await _controller.stopRingtone();
            _showSnackBar('Audio stopped');
          },
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
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildAlarmImage(),
          _buildAudioSelector(),
          _buildVolumeControl(),
          _buildPlaybackControls(),
          const Spacer(),
          _buildBottomNavigation(),
        ],
      ),
    );
  }
}