import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gauge/flutter_gauge.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = new NoiseMeter();
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }

      _currentValue = noiseReading.maxDecibel;
      print(_currentValue);
    });
    print(noiseReading.toString());
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  List<Widget> getContent() => <Widget>[
        // Container(
        //     margin: EdgeInsets.all(25),
        //     child: Column(children: [
        //       Container(
        //         child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
        //             style: TextStyle(fontSize: 25, color: Colors.blue)),
        //         margin: EdgeInsets.only(top: 20),
        //       )
        //     ])),

        Expanded(
          child: FlutterGauge(
              width: 200,
              index: _currentValue,
              fontFamily: "Iran",
              counterStyle: TextStyle(
                color: Colors.black,
                fontSize: 35,
              ),
              numberInAndOut: NumberInAndOut.outside,
              counterAlign: CounterAlign.center,
              secondsMarker: SecondsMarker.secondsAndMinute,
              hand: Hand.short),
        )
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getContent())),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
      ),
    );
  }
}
