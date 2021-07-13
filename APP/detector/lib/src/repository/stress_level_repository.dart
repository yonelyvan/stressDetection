class StressLevelRepository{
  double _stressLevelGSR = 1.0;
  double _stressLevelVoice = 1.0;

  static StressLevelRepository _instance = StressLevelRepository._internal();
  StressLevelRepository._internal();

  factory StressLevelRepository(){
    return _instance;
  }

  double getCurrentStressLevel(){
    /// mix stress level from voice and GSR
    //return _stressLevelGSR+_stressLevelVoice;
    // stress in voice is 1 or 5, just for fusion data
    if(_stressLevelVoice>1){
      _stressLevelVoice = 5.0;
    }else{
      _stressLevelVoice = 1;
    }
    double r = 0.8*_stressLevelGSR + 0.2*_stressLevelVoice;
    return r;
  }

  double getStressValueGSR() => _stressLevelGSR;
  double getStressValueVoice() => _stressLevelVoice;


  void updateStressValueGSR(double v){
    _stressLevelGSR = v;
  }

  void updateStressValueVoice(double v){
    _stressLevelVoice = v;
  }


}