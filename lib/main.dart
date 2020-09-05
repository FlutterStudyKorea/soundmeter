import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:noise_meter/noise_meter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() => runApp(SoundMeterApp());

class SoundMeterApp extends StatefulWidget {
  @override
  _SoundMeterWidget createState() => _SoundMeterWidget();
}

class _SoundMeterWidget extends State<SoundMeterApp> {
  bool _isRecording = false;
  bool _isActive = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  List<double> _items = List<double>();
  double _lastdB = 0.0;
  NoiseMeter _noiseMeter = new NoiseMeter();

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
      _items.add(double.parse(noiseReading.meanDecibel.toStringAsFixed(1)));
      _lastdB = double.parse(noiseReading.meanDecibel.toStringAsFixed(1));
    });
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

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
              // return 'MAR';
              case 5:
              // return 'JUN';
              case 8:
              // return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 10:
                return '10dB';
              case 30:
                return '30dB';
              case 50:
                return '50dB';
              case 70:
                return '70dB';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: [FlSpot(0, 0)],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
          appBar: AppBar(
            title: Text('현재 dB : $_lastdB'),
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: _isRecording ? Colors.red : Colors.green,
              onPressed: _isRecording ? stop : start,
              child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
          body: Stack(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                    color: Color(0xff232d37)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 18.0, left: 12.0, top: 24, bottom: 12),
                  child: sfRadialGaugeWidget(),
                ),
              ),
            ],
          )),
    );
  }

  SfRadialGauge sfRadialGaugeWidget() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(minimum: 0, maximum: 150, ranges: <GaugeRange>[
        GaugeRange(
            startValue: 0,
            endValue: 50,
            color: Colors.green,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 50,
            endValue: 100,
            color: Colors.orange,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 100,
            endValue: 150,
            color: Colors.red,
            startWidth: 10,
            endWidth: 10)
      ], pointers: <GaugePointer>[
        NeedlePointer(value: _lastdB)
      ], annotations: <GaugeAnnotation>[
        GaugeAnnotation(
            widget: Container(
                child: Text('$_lastdB',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
            angle: 90,
            positionFactor: 0.5)
      ])
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isActive = true;
      print("Resume app");
    } else if (_isActive) {
      print("Pause app");
      _isActive = false;
    }
  }
}
