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
      child: Container(

        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child:
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
  final String matches;
  final String lscore;
  const Album({
    required this.text,
    required this.polarity,
    required this.subjectivity,
    required this.matches,
    required this.lscore
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        lscore: json['listenability_score'].toString(),
        text: json['text'].toString(),
        polarity: json['polarity'].toString(),
        subjectivity: json['subjectivity'].toString(),
        matches: json['match_list'].toString()
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
                const Align(alignment: Alignment.center, child: Text("\nSpeech Report\n", textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0, color:Colors.green, fontFamily: 'Poppins', fontWeight: FontWeight.w900),),),
                Center(child: Container(height: 80,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  alignment: Alignment.center,
                child: Center(child: Text("Listenability Score: ${snapshot.data!.lscore}", style: const TextStyle(fontSize: 22.0, color:Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500),),),),),
                const Text("\n"),

                Container(
                  width: 230,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: EdgeInsets.fromLTRB(20,0,20,0),
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const Text("\nHow will it sound to the listeners?", style: TextStyle(fontSize: 18.0, color:Colors.blue, fontFamily: 'Poppins', fontWeight: FontWeight.bold),),
                      Text("\nYour speech will sound ${snapshot.data!.polarity} and ${snapshot.data!.subjectivity} to the listeners. It is considered a good practice to keep it positive and base it on facts. Since the sentiment of the speech depends upon the speaker, it is not considered a significant factor for calculating the score.", style: const TextStyle(fontSize: 16.0, color:Colors.blue, fontFamily: 'Poppins'),),
                      const Text("\nGrammatical Errors", style: TextStyle(fontSize: 18.0, color:Colors.red, fontFamily: 'Poppins', fontWeight: FontWeight.bold),),
                      Text("\n${snapshot.data!.matches}", style: const TextStyle(fontSize: 16.0, color:Colors.red, fontFamily: 'Poppins'),),
                    ],
                  ),
                ),

                const Text("\n"),


                Container(
                  width: 230,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.fromLTRB(20,0,20,0),
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Transcript",
                        style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      Text(
                        "\n${snapshot.data!.text}",
                        style: const TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
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