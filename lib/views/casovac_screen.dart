/// CasovacScreen - obrazovka casovaca pre Flutter aplikaciu
///
///Autor: Ján Findra xfindr01 - Výber času a predvolené časy
///Autor: Filip Botlo xbotlo01 - Aktivačné tlačítka a budík
///
/// Táto obrazovka umožňuje užívateľom nastaviť a ovládať časovač
/// pre rôzne účely. Užívateľ môže vybrať vlastný čas, alebo využiť
/// predvolené časové intervaly.
///
/// ## Funkcionalita
/// - Umožňuje nastaviť časovač na konkrétny čas pomocou CupertinoTimerPicker.
/// - Poskytuje možnosti štartu, zastavenia a resetu časovača.
/// - Integrácia s AudioPlayerom pre prehratie zvuku pri dosiahnutí nuly.
/// - Možnosť výberu prednastavených časových intervalov.
///
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/profile_info.dart';
import 'package:vyperto/model/profile.dart';
import 'package:flutter/cupertino.dart';

class CasovacScreen extends StatefulWidget {
  const CasovacScreen({super.key});

  @override
  _CasovacScreenState createState() => _CasovacScreenState();
}

class _CasovacScreenState extends State<CasovacScreen> {
  Timer? _timer;
  Duration _duration = Duration();
  Duration selectedDuration = Duration(hours: 0, minutes: 0, seconds: 0);
  bool _isRunning = false;
  String _selectedPreset = '';
  AudioPlayer audioPlayer = AudioPlayer();

  /// Filip  zaciatok
  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
        setState(() => _isRunning = false);
        _playSound(); // zahra budik na nule
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
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: CupertinoColors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: Text("Zrušiť"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text("Uložiť"),
                      onPressed: () {
                        setState(() {
                          _duration = selectedDuration;
                          _selectedPreset = '';
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hms,
                      initialTimerDuration: selectedDuration,
                      onTimerDurationChanged: (Duration duration) {
                        setState(() {
                          selectedDuration = duration;
                        });
                      }),
                )
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  /// Autor: Jan Findra (xfindr01)
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
            color: isSelected
                ? Colors.blue
                : const Color.fromARGB(255, 194, 178, 178),
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
              child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                Profile fetchedProfile = profileProvider.profile;
                return ProfileHeader(profile: fetchedProfile);
              }),
            ),

            /// Filip zaciatok
            const SizedBox(height: 40),
            InkWell(
              onTap: _setCustomTime,
              child: Text(
                '${_duration.inHours.toString().padLeft(2, '0')}:${(_duration.inMinutes % 60).toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                    fontSize: 60,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: _isRunning ? null : _startTimer,
                    child: const Text('Štart')),
                ElevatedButton(
                    onPressed: _stopTimer, child: const Text('Stop')),
                ElevatedButton(
                    onPressed: _resetTimer, child: const Text('Reset'))
              ],

              /// Filip koniec
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Predvoľby',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _customTimeTile('45 min'),
            const SizedBox(height: 20),
            _customTimeTile('60 min'),
            const SizedBox(height: 20),
            _customTimeTile('90 min'),
          ],
        ),
      ),
    );
  }
}
