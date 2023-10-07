
import 'dart:developer';
import 'package:http/http.dart' as http;
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
                onRecordComplete: (value) async {
                  log('$value');
                  setState(() {
                    test = value;
                  });
                  var request = http.MultipartRequest('POST', Uri.parse("https://speechwiz-api.neeltron.repl.co/upload"));
                  request.files.add(await http.MultipartFile.fromPath("file", "$value"));
                  print(value);
                  var response = await request.send();
                  print(response);
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
