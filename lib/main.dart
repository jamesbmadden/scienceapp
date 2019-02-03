import 'dart:async';

import 'package:clipboard_manager/clipboard_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Science App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Spectral'
      ),
      home: MyHomePage(title: 'Science App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

num getAverage(List<num> numbers) {
  num total = 0;
  numbers.forEach((num number) {
    total += number;
  });
  return total/numbers.length;
}

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel('jamesbmadden.scienceapp/noise');
  bool initiated = false;

  String output = "";

  int _noise = 0;

  num average = 0;

  int countdownInt = 0;

  num milliseconds = 200;

  num startDelay = 5;
  num endDelay = 20;

  List<int> noises = [];

  bool running = false;
  bool countdown = false;

  Timer loop;

  Future<void> _getNoise() async {
    int noise; 
    try {
      noise = await platform.invokeMethod('getMaxAmp');
      noises.add(noise);
    } catch (e) {
      noise = 0;
      print(e.message);
    }

    setState(() {
      _noise = noise;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder( builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(color:Colors.red),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              '${running ? countdown ? 'Starting In' : 'Amplitude' : 'Average'}', 
                              style: Theme.of(context).textTheme.display1,
                            ),
                            Text(
                              '${running ? countdown ? '$countdownInt Seconds' : _noise : average}', 
                              style: Theme.of(context).textTheme.display1,
                            )
                          ]
                        )
                      )
                    ],
                  )
                ),
                Card(
                  child:Row(
                    children: <Widget>[
                      _buildButton('Start Mic', () async {
                        print('starting mic');
                        try {
                          await platform.invokeMethod('micOn');
                          print('mic started');
                          setState(() {
                            running = true;
                          });
                          setState(() {
                            countdownInt = startDelay;
                            countdown = true;
                          });
                          Timer.periodic(new Duration(seconds: 1), (timer) {
                            setState(() {
                              countdownInt--;
                            });
                            print(countdownInt);
                            if (countdownInt <= 0) {
                              setState(() {
                                countdown = false;
                              });
                              timer.cancel();
                            }
                          });
                          Timer(new Duration(seconds:startDelay), () async {
                            await platform.invokeMethod('getMaxAmp');
                            // Create loop
                            noises = [];
                            print('starting loop');
                            num i = 0;
                            loop = Timer.periodic(new Duration(milliseconds:milliseconds), (timer) async {
                              _getNoise();
                              i += milliseconds;
                              if (i > endDelay*1000) {
                                // Stop Mic
                                try {
                                  loop.cancel(); // Cancel the loop
                                  await platform.invokeMethod('micOff'); // Turn off the mic
                                  setState(() {
                                    _noise = -1; // Update UI
                                    average = getAverage(noises);
                                    running = false;
                                    print(noises);
                                    output = noises.join(', '); // Create String
                                    ClipboardManager.copyToClipBoard(output).then((result) { // Copy to Clipboard
                                      final snackBar = SnackBar(
                                        content: Text('Results Copied to Clipboard')
                                      );
                                      Scaffold.of(context).showSnackBar(snackBar);
                                    });
                                  });
                                } catch (e) {

                                }
                              }
                            });
                            setState(() {
                              running = true;
                            });
                          });
                        } catch (e) {
                          print(e.message);
                          setState(() {
                            running = false;
                          });
                        }
                      })
                    ]
                  )
                )
              ],
            ),
          ),
        );
      })
    );
  }

  Widget _buildButton(String text, Function func) {
    return new RaisedButton(
      child:new Text(text),
      onPressed: running ? null : func
    );
  }
}