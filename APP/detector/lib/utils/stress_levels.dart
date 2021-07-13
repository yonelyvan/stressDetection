import 'dart:math';

import 'package:flutter/material.dart';

class StressLevelsProcessing {
  final List<double> signal;

  StressLevelsProcessing({@required this.signal});

  // 1) Preprocesing (noise reduction)
  List<double> medianFilter(List<double> signal) {
    int lenFilter = 25; //TODO: default 100;
    int lenSignal = signal.length;
    List<double> suavizado = [];
    int mitad = lenFilter ~/ 2; //divicion entera
    for (int i = 0; i < lenSignal; i++) {
      int initIndex = i - mitad;
      double s = 0;
      int counter = 0;
      for (int f = 0; f < lenFilter; f++) {
        int currentIndex = initIndex + f;
        //check valid current index
        if (0 < currentIndex && currentIndex < lenSignal) {
          s += signal[currentIndex]; // *filter[f] o (*1)
          counter += 1;
        }
      }
      suavizado.add(s / counter);
    }
    return suavizado;
  }

  //2 Agregation
  List<double> aggregation(List<double> signal) {
    int lenFilter = 60; //TODO: default 240(4hz)  1 minute sampling
    List<double> aggregated = [];
    int lenSignal = signal.length;
    int mitad = lenFilter ~/ 2;
    for (int i = 0; i < lenSignal; i++) {
      int initIndex = i - mitad;
      double maxValue = 0.0;
      for (int f = 0; f < lenFilter; f++) {
        int currentIndex = initIndex + f;
        //check valid current index
        if (0 < currentIndex && currentIndex < lenSignal) {
          maxValue = max(maxValue, signal[currentIndex]);
        }
      }
      aggregated.add(maxValue);
    }
    return aggregated;
  }

  // 3) Discretization
  double mean(List<double> signal) {
    double s = 0;
    signal.forEach((double e) {
      s += e;
    });
    return s / (signal.length);
  }

  double standardDeviation(List<double> signal) {
    double variance = 0.0;
    double m = mean(signal);
    for (int i = 0; i < signal.length; ++i) {
      variance += pow(signal[i] - m, 2.0);
    }
    double stdDeviation = sqrt(variance / signal.length);
    return stdDeviation;
  }

  List<double> znorm(List<double> signal, {double znormTheshold = 0.01}) {
    List<double> r = [];
    double std = standardDeviation(signal);
    print("STD: $std");
    if (std < znormTheshold) {
      return signal;
    } else {
      double m = mean(signal);
      print("Media: $m");
      signal.forEach((e) {
        r.add((e - m) / std);
      });
      return r;
    }
  }

  List<double> paa(List<double> series, int paaSegments) {
    int seriesLen = series.length;
    //check for the trivial case
    if (seriesLen == paaSegments) {
      return series;
    } else {
      return series;
      //todo: not using for this project
    }
  }

  List<double> aggregationPAA(List<double> signal) {
    List<double> datZnorm = znorm(signal);
    List<double> r = paa(datZnorm, signal.length);
    return r;
  }

  // 3.1 -----------------final dicretization

// Convert a numerical index to a char
  String idx2letter(int idx) {
    if (0 <= idx && idx < 5) {
      return String.fromCharCode(97 + idx);
    } else {
      String text = "Warning: idx2letter idx out of range";
      print("\x1B[33m$text\x1B[0m");
      return String.fromCharCode(97);
    }
  }

// num-to-string conversion.
  List<String> ts_to_string(List<double> series, List<double> cuts) {
    int a_size = cuts.length;
    List<String> sax = [];
    for (int i = 0; i < series.length; i++) {
      double num = series[i];
      //if the number below 0, start from the bottom, or else from the top
      int j;
      if (num >= 0) {
        j = a_size - 1;
        while ((j > 0) && (cuts[j] >= num)) {
          j = j - 1;
        }
        sax.add(idx2letter(j));
      } else {
        j = 1;
        while ((j < a_size) && (cuts[j] <= num)) {
          j = j + 1;
        }
        sax.add(idx2letter(j - 1));
      }
    }
    return sax;
  }

  List<double> cuts_for_asize(int a_size) {
    double inf = 999999;
    Map<int, List<double>> options = {
      3: [-inf, -0.4307273, 0.4307273],
      5: [
        -inf,
        -0.841621233572914,
        -0.2533471031358,
        0.2533471031358,
        0.841621233572914
      ]
    };
    return options[a_size] as List<double>;
  }

  List<int> discretizar(List<double> signal) {
    Map<String, int> alphabet_values = {
      'a': 1,
      'b': 2,
      'c': 3,
      'd': 4,
      'e': 5
    }; //*
    List<String> abc =
        ts_to_string(signal, cuts_for_asize(5)); // abc : (cadena de String)
    List<int> r = [];
    for (int i = 0; i < abc.length; i++) {
      int val = alphabet_values[abc[i]] as int;
      r.add(val);
    }
    return r;
  }

  List<double> getResult() {
    List<double> signalSuavizado = medianFilter(signal);
    List<double> aggregated = aggregation(signalSuavizado);
    List<double> ppaV = aggregationPAA(aggregated);
    List<int> eda_discretizado = discretizar(ppaV);
    List<double> r = [];
    eda_discretizado.forEach((e) {
      r.add(e * 1.0);
    });

    return r;
  }
}
