import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../bloc/record_bloc.dart';
import '../../model/record.dart';
import '../../repository/files.dart';

class ScreenRecorderSignal extends StatefulWidget{

  @override
  _ScreenRecorderSignal createState() {
    return _ScreenRecorderSignal();
  }
}

class _ScreenRecorderSignal extends State<ScreenRecorderSignal> {
  final RecordBloc _recordBloc = RecordBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _recordBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
              children: [
                Text("record signal"),
              ],
            )
        ),
        floatingActionButton:
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: (){
              _dialogInsert(context);
            },
            heroTag: null,
          ),

        ])

    );

  }


  _saveSignal(){
    String filename = "CS2303";
    List<int> signal= [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
    print(">>>filename: $filename");
    print(">>>>>signal: $signal");


    //todo SAVE
    Files files = Files();
    DateTime current = DateTime.now();
    Record record = Record(filename: filename ,date: current, samples: 0);
    ///write on disk
    files.writeSignal(signal: signal, record: record);
    ///write on db
    _recordBloc.addRecord.add(record);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> finish on: ui_screen_record");
  }




  /// Dialoig to insert
  void _dialogInsert(BuildContext context) {
    List<int> signal= [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
    Record record = Record( filename: "", date: DateTime.now(), samples: signal.length);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            //title: Text(Translations.of(context).text("new_option")),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        record.filename = value;
                      },
                      decoration: InputDecoration(
                          labelText: "file name"),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("save"),
                onPressed: () {
                  Navigator.of(context).pop();
                  String str = record.filename.trim();
                  if (str.compareTo("") == 0) {
                    Fluttertoast.showToast(
                        msg: "toast_no_word");
                  } else {
                    record.filename = "${record.filename}.csv";
                    Files files = Files();
                    ///write on disk
                    files.writeSignal(signal: signal, record: record);
                    ///write on db
                    _recordBloc.addRecord.add(record);
                  }
                },
              )
            ],
          );
        });
  }
}
