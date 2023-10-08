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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeechWiz',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SpeechWiz'),
        ),
        body: _bfI(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Record',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Results',
            ),
          ],
        ),
      ),
    );
  }

  Widget _bfI(int index) {
    switch (index) {
      case 0:
        return _recScreen();
      case 1:
        return _resScreen();
      default:
        return Container();
    }
  }

  Widget _recScreen() {
    return Center(
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
    );
  }

  Widget _resScreen() {
    return const Center(
      child: Text('Results go hereeee'),
    );
  }
}
