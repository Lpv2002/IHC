import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_speech/text_to_speech.dart';

import 'app_body.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatPelis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'ChatPelis'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DialogFlowtter dialogFlowtter;

  late stt.SpeechToText _speech;
  String _text = '';
  bool _isListening = false;
  late Timer _timer;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatPelis',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 54, 52, 48),
        leading: IconButton(
          icon: Icon(
            Icons.local_movies,
            color: Colors.white,
          ),
          onPressed: () {
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: AppBody(messages: messages)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            color: const Color.fromARGB(157, 2, 61, 109),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _listen();
                  },
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });


    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );
    TextToSpeech tts = TextToSpeech();
    tts.setLanguage('es-Es');
    tts.speak(response.text as String);

    if (response.message == null) return;
    setState(() {
      addMessage(response.message!);
    });
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );

        _timer = Timer(Duration(seconds: 3), () {
          // Detiene la escucha después de 10 segundos
          setState(() => _isListening = false);
          _speech.stop();
          sendMessage(_text);
          TextToSpeech tts = TextToSpeech();
          double pitch = 1.0;
          tts.setPitch(pitch);
          tts.setLanguage('es-ES');
          _timer?.cancel();
        });
      }
    }
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }
}
