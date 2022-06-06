import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentLog = "log";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'LOG: $currentLog',
              ),
            ],
          ),
        ),
        floatingActionButton:
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            child: Icon(Icons.share),
            onPressed: _shareFile,
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.remove_red_eye),
            onPressed: _readFile,
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: _saveFile,
            heroTag: null,
          )
        ]) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _updateLog(String value){
    setState(() {
      currentLog = value;
    });
  }


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/CS25GSR.csv');
  }


  // input: GSR values: [x1, x2, ..., xn]
  // output: csv format with GSR data
  String getDataGSR(List<int> signal){
    List<List<dynamic>> rows = [];
    for(int e in signal) {
      List<dynamic> d = [];
      d.add(e);
      rows.add(d);
    }
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  Future<File> writeCounter(List<int> signal) async {
    String str = getDataGSR(signal);
    final file = await _localFile;
    return file.writeAsString(str);
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      print(">>>>>>>>>>>>>>>>>>contents");
      print(contents);
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }


  void _saveFile() {
    _updateLog("Save File");
    print("\n >>>>>>>>>>>>>>>>>>");
    List<int> signal= [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
    writeCounter(signal);
    print(">>>>>>>>>>>>>saving file...\n");
  }

  void _readFile() {
    readCounter().then((value){
      _updateLog("Read File");
      print(">>>>>>>>>>>>>>");
      print(value);
      print(">>>>>>>>>>>>>>");
    });
  }

  void _shareFile() async {
    final file = await _localFile;
    _updateLog("Share File");
    Share.shareFiles([file.path], text: 'Archivo prueba');
  }


}
