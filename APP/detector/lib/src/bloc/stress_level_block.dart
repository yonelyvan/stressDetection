import 'dart:async';

import 'package:detector/src/repository/stress_level_repository.dart';

class StressLevelBase{}
class UpdateStressLevelGSR extends StressLevelBase {
  final double stressValueGSR;
  UpdateStressLevelGSR(this.stressValueGSR);
}
class UpdateStressLevelVoice extends StressLevelBase {
  final double stressValueVoice;
  UpdateStressLevelVoice(this.stressValueVoice);
}
class FetchEvent extends StressLevelBase{}

class StressLevelBlock{
  //variables
  StressLevelRepository repository = StressLevelRepository();

  //streams
  StreamController<StressLevelBase> _input = StreamController();

  StreamController<double> _outputGSR = StreamController();
  StreamController<double> _outputVoice = StreamController();
  StreamController<double> _outputCurrentStressLevel = StreamController();

  // :listen ui
  Stream<double> get stressLevelGSRStream => _outputGSR.stream;
  Stream<double> get stressLevelVoiceStream => _outputVoice.stream;
  Stream<double> get currentStressLevelStream => _outputCurrentStressLevel.stream;
  StreamSink<StressLevelBase> get sendEvent => _input.sink;


  StressLevelBlock(){
    _input.stream.listen( _onEvent);
  }

  void dispose(){
    _input.close();
    _outputGSR.close();
    _outputVoice.close();
    _outputCurrentStressLevel.close();
  }

  void _onEvent(StressLevelBase event){
    if(event is UpdateStressLevelGSR){
      repository.updateStressValueGSR(event.stressValueGSR);
      print("Block: Stress value GSR (update): ${repository.getStressValueGSR()}");
      _outputGSR.add(repository.getStressValueGSR());
    }
    if(event is UpdateStressLevelVoice){
      repository.updateStressValueVoice(event.stressValueVoice);
      print("Block: Stress value Voice (update):${repository.getStressValueVoice()}");
      _outputVoice.add(repository.getStressValueVoice());
    }
    //send global stress value
    print("Block:  Stress value Voice:${repository.getCurrentStressLevel()}");
    _outputCurrentStressLevel.add(repository.getCurrentStressLevel());

  }



}


