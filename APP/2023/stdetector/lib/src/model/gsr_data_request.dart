import 'dart:convert';

class GsrDataRequest {
  int gsr;
  int currentStressLevel;
  String dateTime;

  GsrDataRequest({
    required this.gsr,
    required this.currentStressLevel,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'gsr': gsr,
      'current_stress_level': currentStressLevel,
      'date_time': dateTime,
    };
  }
}


