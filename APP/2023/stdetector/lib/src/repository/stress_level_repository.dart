
import 'package:stdetector/src/model/gsr_data_request.dart';

class StressLevelRepository{
  int _stressLevelGSR = 1;

  static StressLevelRepository _instance = StressLevelRepository._internal();
  StressLevelRepository._internal();

  factory StressLevelRepository(){
    return _instance;
  }

  int getCurrentStressLevel(){
    int r = _stressLevelGSR;
    return r;
  }

  int getStressValueGSR() => _stressLevelGSR;

  void updateStressValueGSR(int v){
    _stressLevelGSR = v;
  }



}