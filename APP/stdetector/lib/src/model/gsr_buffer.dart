import 'dart:collection';
import 'package:stdetector/utils/stress_levels.dart';

import 'gsr_data.dart';

class GSRBuffer {
  late Queue<double> _queue;
  /// the maximum frames in real time. Case: if 4hz there are 4*60 in 1 minute
  int _maxBuffer = 60*30;
  int _currentStressLevel = 1;

  GSRBuffer() {
    _queue = Queue<double>();
  }

  void push(double value) {
    if (_queue.length >= _maxBuffer) {
      _queue.removeFirst();
    }
    _queue.add(value);
  }

  void clear(){
    if(_queue.length>0){
      _queue.clear();
    }
  }

  /// GET data to plot the signal
  List<GSRData> getData() {
    List<GSRData> data = [];//new List<GSRData>();
    int cont = 0;
    String time = "0";
    for (double e in _queue) {
      time = cont.toString();
      data.add(GSRData(time: time, value: e));
      cont++;
    }
    return data;
  }

  //TODO: process stress levels
  List<GSRData>  getProcessData(){
    StressLevelsProcessing stressLevelsProcessing = new StressLevelsProcessing(signal: getSignalBuffer());
    List<double> r = stressLevelsProcessing.getResult();
    List<GSRData> data = [];
    for(int i=0; i<r.length; i++){
      String time = i.toString();
      data.add(GSRData(time: time, value: r[i]));
    }
    if(r.length>0){
      _currentStressLevel = (r[r.length-1]).round();//el ultimo nivel
    }

    return data;
  }

  int get CurrentStressLevel => _currentStressLevel;

  int min(int a, int b) => a<b?a:b;

  List<List<int>> getMatrixSignalAndStressLevels(){
    List<List<int>> r = [];
    List<double> signal = getSignalBuffer();
    List<GSRData> level = getProcessData();
    List<int> s = [];
    List<int> sl = [];
    for(double e in signal){
      s.add(e.toInt());
    }
    for(GSRData e in level){
      sl.add(e.value.toInt());
    }
    int l = min(s.length,sl.length);
    for(int i =0; i<l; i++){
      r.add( [s[i], sl[i]] );
    }
    return r;
  }


  List<double> getSignalBuffer() => _queue.toList();

  int get length => _queue.length;
  int get timeInSeconds => _queue.length;
  double get timeInMinutes{
    return (_queue.length)/60.0;
  }


}
