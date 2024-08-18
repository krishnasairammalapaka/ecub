import 'package:ecub_s1_v2/service_page/FoodService/FS_HomeScreen.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_home.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionScreen extends StatefulWidget {
  @override
  _SpeechRecognitionScreenState createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  SpeechToText speechtotext = SpeechToText();
  var textSpeech = "click to record";
  bool isListening = false;

  final List<String> commands = [
    "-feeling hungry I want to order some food",
    "-I want to consult a doctor",
    "-book a ride",
    "-hire a maid or a cleaning service",
    "",
    "-Any thing you wish for"
    // Add more commands here
  ];

  void checkMic() async {
    bool micAvailable = await speechtotext.initialize();
    if (micAvailable) {
      print("Mic is available");
      setState(() {
        isListening = true;
      });
      speechtotext.listen(
          listenFor: Duration(seconds: 20),
          onResult: (result) {
            setState(() {
              textSpeech = result.recognizedWords;
              isListening = false;
            });
            print(textSpeech.toLowerCase());
            final lowerCaseText = textSpeech.toLowerCase();
            if (lowerCaseText.contains("medical") ||
                lowerCaseText.contains("wheelchair") ||
                lowerCaseText.contains("oxygen")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MeHomePage()),
              );
            } else if (lowerCaseText.contains("home")) {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/home2", (r) => false);
            } else if (lowerCaseText.contains("biryani")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FS_HomeScreen()),
              );
              Navigator.pushNamed(context, '/fs_dishes',
                  arguments: {'title': 'biryani', 'type': 'biryani'});
            } else if (lowerCaseText.contains("pizza")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FS_HomeScreen()),
              );
              Navigator.pushNamed(context, '/fs_dishes',
                  arguments: {'title': 'pizza', 'type': 'pizza'});
            } else if (lowerCaseText.contains("burger")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FS_HomeScreen()),
              );
              Navigator.pushNamed(context, '/fs_dishes',
                  arguments: {'title': 'burger', 'type': 'burger'});
            } else if (lowerCaseText.contains("salad")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FS_HomeScreen()),
              );
              Navigator.pushNamed(context, '/fs_dishes',
                  arguments: {'title': 'salad', 'type': 'salad'});
            } else if (lowerCaseText.contains("food") ||
                lowerCaseText.contains("biryani") ||
                lowerCaseText.contains("pizza")) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FS_HomeScreen()),
              );
            } else if (lowerCaseText.contains("taxi") ||
                lowerCaseText.contains("ride") ||
                lowerCaseText.contains("bike")) {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rb');
            } else if (lowerCaseText.contains("doctor") ||
                lowerCaseText.contains("physician")) {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dc');
            } else if (lowerCaseText.contains('cleaning') ||
                lowerCaseText.contains("maid") ||
                lowerCaseText.contains("washing")) {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cs');
            }
          });
    } else {
      print("Mic is not available");
    }
  }

  @override
  void initState() {
    super.initState();
    checkMic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Try saying",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    commands.join("\n"),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                textSpeech,
                style: TextStyle(fontSize: 20),
              ),
              GestureDetector(
                onTap: () async {
                  if (!isListening) {
                    bool micAvailable = await speechtotext.initialize();
                    if (micAvailable) {
                      setState(() {
                        isListening = true;
                      });
                      speechtotext.listen(
                          listenFor: Duration(seconds: 20),
                          onResult: (result) {
                            setState(() {
                              textSpeech = result.recognizedWords;
                              isListening = false;
                            });
                            print(textSpeech.toLowerCase());
                            final lowerCaseText = textSpeech.toLowerCase();
                            if (lowerCaseText.contains("medical") ||
                                lowerCaseText.contains("wheelchair") ||
                                lowerCaseText.contains("oxygen")) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => MeHomePage()),
                              );
                            } else if (lowerCaseText.contains("biryani")) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => FS_HomeScreen()),
                              );
                              Navigator.pushNamed(context, '/fs_dishes',
                                  arguments: {
                                    'title': 'biryani',
                                    'type': 'biryani'
                                  });
                            } else if (lowerCaseText.contains("pizza")) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => FS_HomeScreen()),
                              );
                              Navigator.pushNamed(context, '/fs_dishes',
                                  arguments: {
                                    'title': 'pizza',
                                    'type': 'pizza'
                                  });
                            } else if (lowerCaseText.contains("burger")) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => FS_HomeScreen()),
                              );
                              Navigator.pushNamed(context, '/fs_dishes',
                                  arguments: {
                                    'title': 'burger',
                                    'type': 'burger'
                                  });
                            } else if (lowerCaseText.contains("salad")) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => FS_HomeScreen()),
                              );
                              Navigator.pushNamed(context, '/fs_dishes',
                                  arguments: {
                                    'title': 'salad',
                                    'type': 'salad'
                                  });
                            } else if (lowerCaseText.contains("home")) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/home2", (r) => false);
                            }
                            //  else if (lowerCaseText.contains("food") ||
                            //     lowerCaseText.contains("biryani") ||
                            //     lowerCaseText.contains("pizza")) {
                            //   Navigator.pop(context);
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //         builder: (context) => FS_HomeScreen()),
                            //   );
                            // }
                            else if (lowerCaseText.contains("taxi") ||
                                lowerCaseText.contains("ride") ||
                                lowerCaseText.contains("bike")) {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/rb');
                            } else if (lowerCaseText.contains("doctor") ||
                                lowerCaseText.contains("physician")) {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/dc');
                            } else if (lowerCaseText.contains('cleaning') ||
                                lowerCaseText.contains("maid") ||
                                lowerCaseText.contains("washing")) {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/cs');
                            }
                          });
                    }
                  } else {
                    setState(() {
                      isListening = false;
                      speechtotext.stop();
                    });
                  }
                },
                child: CircleAvatar(
                  child: isListening
                      ? Icon(Icons.record_voice_over)
                      : Icon(Icons.mic),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
