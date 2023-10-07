
import 'dart:developer';

import 'package:fancy_audio_recorder/fancy_audio_recorder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SpeechWiz());

class SpeechWiz extends StatefulWidget {
  const SpeechWiz({super.key});

  @override
  State<SpeechWiz> createState() => _SpeechWizState();
}

class _SpeechWizState extends State<SpeechWiz> {
  String? test;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeechWiz',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SpeechWiz'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AudioRecorderButton(
                maxRecordDuration: const Duration(seconds: 80),
                onRecordComplete: (value) {
                  log('$value');
                  setState(() {
                    test = value;
                  });
                },
              ),
              Text('$test'),
            ],
          ),
        ),
      ),
    );
  }
}
