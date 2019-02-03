import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Science App',
      theme: ThemeData(
        // This is the theme of your application.
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

class _MyHomePageState extends State<MyHomePage> {

  static const platform = const MethodChannel('jamesbmadden.scienceapp/noise');
  bool initiated = false;

  double _noise = 0.0;

  List<bool> buttons = [
    true,
    false
  ];

  Timer loop;
  

  Future<void> _startMic() async {
    print('starting mic');
    try {
      await platform.invokeMethod('micOn');
      print('mic started');
      setState(() {
        buttons = [
          false,
          true
        ];
      });
      _startLoop();
    } catch (e) {
      print(e.message);
      setState(() {
        buttons = [
          true,
          false
        ];
      });
    }
  }

  Future<void> _getNoise() async {
    double noise; 
    try {
      noise = await platform.invokeMethod('getMaxAmp');
    } catch (e) {
      noise = 0.0;
      print(e.message);
    }

    setState(() {
      _noise = noise;
    });
  }

  void _startLoop() {
    print('starting loop');
    loop = Timer.periodic(new Duration(milliseconds:16), (timer) {
      _getNoise();
    });
    setState(() {
      buttons = [
        false,
        true
      ];
    });
  }

  void _stopMic() async {
    try {
      await platform.invokeMethod('micOff');
      loop.cancel();
      setState(() {
        buttons = [
          true,
          false
        ];
      });
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                            'Amplitude:', 
                            style: Theme.of(context).textTheme.display1,
                          ),
                          Text(
                            '$_noise', 
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
                    _buildButton('Start Mic', 0, _startMic),
                    _buildButton('Stop Mic', 1, _stopMic),
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, int index, Function func) {
    return new RaisedButton(
      child:new Text(text),
      onPressed: buttons[index] ? func : null
    );
  }
}
