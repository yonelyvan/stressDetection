import 'package:flutter/material.dart';
import 'package:stdetector/src/ui/screens/screen_tabs.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detector',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: Home(),
      home: ScreenTabs(),
    );
  }
}


