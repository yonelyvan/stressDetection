class StressLevelRepository{
  int _stressLevelGSR = 1;

  static StressLevelRepository _instance = StressLevelRepository._internal();
  StressLevelRepository._internal();

  factory StressLevelRepository(){
    return _instance;
  }

  int getCurrentStressLevel(){
    /// mix stress level from voice and GSR
    int r = _stressLevelGSR;
    return r;
  }

  int getStressValueGSR() => _stressLevelGSR;


  void updateStressValueGSR(int v){
    _stressLevelGSR = v;
  }



}