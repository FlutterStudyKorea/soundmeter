import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
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
    Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Container(
            child: Text(_isRecording ? "소음측정: 켜기" : "소음측정: 끄기",
                style: TextStyle(fontSize: 25, color: Colors.blue)),
            margin: EdgeInsets.only(top: 20),
          )
        ])),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(


          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '소음 측정 레벨',
              ),
              Container(
                  child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(minimum: 0,maximum: 150,
                            ranges: <GaugeRange>[
                              GaugeRange(startValue: 0,endValue: 50,color: Colors.green,startWidth: 10,endWidth: 10),
                              GaugeRange(startValue: 50,endValue: 100,color: Colors.orange,startWidth: 10,endWidth: 10),
                              GaugeRange(startValue: 100,endValue: 150,color: Colors.red,startWidth: 10,endWidth: 10)],
                            pointers: <GaugePointer>[NeedlePointer(value:90)],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(widget: Container(child:
                              Text('54.0 dB',style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold))),
                                  angle: 90,positionFactor: 0.5)]
                        )]
                  )
              )
,
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getContent()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
      ),
    );
  }
}