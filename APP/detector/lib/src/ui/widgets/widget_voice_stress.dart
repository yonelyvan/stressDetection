import 'package:detector/src/bloc/stress_level_block.dart';
import 'package:detector/src/ui/widgets/stress_levels_legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:detector/utils/circle_painter.dart';
import 'package:detector/utils/curve_wave.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:http/http.dart' as http;

import 'dart:io';

class WidgetVoiceStress extends StatefulWidget {
  final StressLevelBlock stressLevelBlock;

  const WidgetVoiceStress({Key key, @required this.stressLevelBlock}) : super(key: key);

  @override
  _WidgetVoiceStress createState() => _WidgetVoiceStress();
}

class _WidgetVoiceStress extends State<WidgetVoiceStress>
    with TickerProviderStateMixin {
  //bloc

  AnimationController _controller;
  bool _pressed = false;
  List<Color> stressColors = [Colors.blue, Colors.orange, Colors.red];
  List<String> stressLabels = ["Relajado", "Medio Estresado", "Estresado"];
  Color currentColor = Colors.blue;
  String _state = "stop"; //[stop, running]
  String currentStressLabel = " ";
  double size = 80.0;
  //for audio
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  //server
  String urlServer = "http://192.168.0.107:3000";

  //
  int stressValue = 1;

  StreamSubscription periodicSub;

  LocalFileSystem localFileSystem;

  @override
  void initState() {
    localFileSystem = LocalFileSystem();
    super.initState();
    runAnimation();
    stopAnimation(); // :3
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///legend
          //StressLevelLegend(),
          //_widgetLegend(context),
          /// divisor
          Container(
            height: 4,
          ),

          /// animation stress level
          Text(
            "Estrés voz: $currentStressLabel",
            style: TextStyle(fontSize: 14, color: currentColor),
          ),
          CustomPaint(
            painter: CirclePainter(
              _controller,
              color: currentColor,
            ),
            child: SizedBox(
              width: size * 3,
              height: size * 3,
              child: _button(),
            ),
          ),
          Container(
            height: 2,
          ),

        ],
      ),
    );
  }

  /// record voice

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                currentColor,
                Color.lerp(currentColor, Colors.black, .05)
              ],
            ),
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: CurveWave(),
              ),
            ),
            child: IconButton(
              icon: Icon(_pressed ? Icons.stop : Icons.play_arrow_outlined,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _pressed = !_pressed;
                  if (!_pressed) {
                    stopAnimation();
                    print("no esta presionado");
                  } else {
                    runAnimation();
                    print(">>>>>>>>>>>>>>> init process");

                    ///TODO: init process
                    _runDetector();
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  void stopAnimation() {
    _controller.stop();
    if (periodicSub != null) {
      periodicSub.cancel();
    }
  }

  void runAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  _runDetector() {
    periodicSub =
        new Stream.periodic(const Duration(seconds: 10)).take(500).listen((_) {
      if (_state == "stop") {
        _start();
      }
    });
  }

  _sendToServer() {
    _uploadFile(_current.path, urlServer).then((value) {
      _init();
    });
  }

  Future<int> _uploadFile(String filename, String url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url + "/upload"));
    request.files.add(await http.MultipartFile.fromPath('file', filename));
    var res = await request.send();
    print(">" * 40);
    print(res.reasonPhrase);

    print("res.statusCode: ${res.statusCode}");

    String rawData = await res.stream.bytesToString();
    var data = jsonDecode(rawData);
    print("############### $data");
    print("result");
    print(data["result"]);
    _updateStressLevel(data["stress_level"]?.toInt());
    return 0;
  }

  _updateStressLevel(int value) {
    print(">>>>>>>>>>>stress value: $value");
    value = value - 1;
    if (value > 2) {
      //TODO: make sure if the vale is into the range
      print("Error: value out of range");
      value = 2;
    }
    setState(() {
      stressValue = value;
      currentColor = stressColors[value];
      currentStressLabel = stressLabels[value];
      ///_updateBlocStressLevel(value);
    });
    _updateVoiceStressLevel(stressValue.toDouble());
  }

  ///Audio --------------------------------------------
  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder = FlutterAudioRecorder(customPath,
            audioFormat: AudioFormat.WAV, sampleRate: 16000);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    setState(() {
      _state = "running";
    });

    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        if (current.duration.inSeconds >= 3) {
          ///TODO: change static var
          _stop().then((value) {
            print("sent to server >>>");
            _sendToServer();
          });
        }

        setState(() {
          _current = current;
          _currentStatus = _current.status;
          _state = "stop";
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  Future<int> _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
    return 0;
  }

  //bloc
  _updateVoiceStressLevel(double v) {
    widget.stressLevelBlock.sendEvent.add(UpdateStressLevelVoice(v));
  }

} //end class
