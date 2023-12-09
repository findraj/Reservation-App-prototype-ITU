import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/profile_info.dart';
import 'package:vyperto/model/profile.dart';

class CasovacScreen extends StatefulWidget {
  const CasovacScreen({super.key});

  @override
  _CasovacScreenState createState() => _CasovacScreenState();
}

class _CasovacScreenState extends State<CasovacScreen> {
  Timer? _timer;
  Duration _duration = Duration();
  bool _isRunning = false;
  String _selectedPreset = '';
  AudioPlayer audioPlayer = AudioPlayer(); // Create an instance of AudioPlayer

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
        setState(() => _isRunning = false);
        _playSound(); // Play sound when timer reaches zero
      } else {
        setState(() => _duration -= const Duration(seconds: 1));
      }
    });
  }

  void _playSound() async {
    AudioPlayer audioPlayer = AudioPlayer();
    try {
      await audioPlayer.play(AssetSource('lg_washer.mp3'));
    } catch (e) {
      // Log or handle the error here
      print("Error playing sound: $e");
    }
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _isRunning = false);
    }
  }

  void _resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _duration = Duration();
      _isRunning = false;
      _selectedPreset = '';
    });
  }

  Future<void> _setCustomTime() async {
    TextEditingController hoursController = TextEditingController();
    TextEditingController minutesController = TextEditingController();
    TextEditingController secondsController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Custom Time'),
          content: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Hours"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Minutes"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: secondsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Seconds"),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Set'),
              onPressed: () {
                final int hours = int.tryParse(hoursController.text) ?? 0;
                final int minutes = int.tryParse(minutesController.text) ?? 0;
                final int seconds = int.tryParse(secondsController.text) ?? 0;
                setState(() {
                  _duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
                  _selectedPreset = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  Widget _customTimeTile(String time) {
    bool isSelected = _selectedPreset == time;
    return InkWell(
      onTap: () {
        final minutes = int.parse(time.split(' ')[0]);
        _duration = Duration(minutes: minutes);
        _selectedPreset = time;
        _startTimer();
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : const Color.fromARGB(255, 194, 178, 178),
            width: 1,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(color: isSelected ? Colors.blue : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
        child: Column(
          children: [
            Container(
              child: Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
                Profile fetchedProfile = profileProvider.profile;
                return ProfileHeader(profile: fetchedProfile);
              }),
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: _setCustomTime,
              child: Text(
                '${_duration.inHours.toString().padLeft(2, '0')}:${(_duration.inMinutes % 60).toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 60, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ElevatedButton(onPressed: _isRunning ? null : _startTimer, child: const Text('Start')), ElevatedButton(onPressed: _stopTimer, child: const Text('Stop')), ElevatedButton(onPressed: _resetTimer, child: const Text('Reset'))],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _customTimeTile('7 min'),
            const SizedBox(height: 20),
            _customTimeTile('48 min'),
            const SizedBox(height: 20),
            _customTimeTile('90 min'),
          ],
        ),
      ),
    );
  }
}
