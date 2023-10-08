import 'dart:convert';
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
  void initState() {
    super.initState();
    Future<Album> futureAlbum = fetchAlbum();
  }
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
            maxRecordDuration: const Duration(seconds: 300),
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

        ],
      ),
    );
  }

  Widget _resScreen() {
    return getRequest();
  }
}

Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://speechwiz-api.neeltron.repl.co/export'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class Album {
  final String text;
  final String polarity;
  final String subjectivity;
  const Album({
    required this.text,
    required this.polarity,
    required this.subjectivity
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        text: json['text'].toString(),
        polarity: json['polarity'].toString(),
        subjectivity: json['subjectivity'].toString()
    );
  }
}

Widget getRequest() {
  final formKey = GlobalKey<FormState>();
  Future<Album> futureAlbum = fetchAlbum();
  return FutureBuilder<Album>(    future: futureAlbum,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(alignment: Alignment.center, child: Text("\nSpeech Report", textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0, color:Colors.green, fontFamily: 'Poppins'),),),
                Text("\nTranscript: \n${snapshot.data!.text}", style: const TextStyle(fontSize: 16.0, color:Colors.blue, fontFamily: 'Poppins'),),
                Text("\nHow will it sound to the listeners?: \n${snapshot.data!.polarity} and ${snapshot.data!.subjectivity}", style: const TextStyle(fontSize: 16.0, color:Colors.blue, fontFamily: 'Poppins'),),
              ],
            ),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const Center(child: CircularProgressIndicator());
    },
  );
}