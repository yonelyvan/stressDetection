import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import '../../../pair.dart';
import '../../bloc/record_bloc.dart';
import '../../model/record.dart';
import '../../repository/files.dart';
import '../widgets/widget_record.dart';

class ScreenRecorders extends StatefulWidget {
  @override
  _ScreenRecorders createState() {
    return _ScreenRecorders();
  }
}

class _ScreenRecorders extends State<ScreenRecorders> {
  final RecordBloc _recordBloc = RecordBloc();
  bool editing = false;
  Map<dynamic, Record> _selectedRecords = Map<dynamic, Record>();

  @override
  void initState() {
    super.initState();
    //_taskBloc.readTasks.add(widget.project);
  }

  @override
  void dispose() {
    super.dispose();
    _recordBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
        title: Text("Records"),
        actions: <Widget>[isEditing() ? options(context) : Text("")],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          ///padding: EdgeInsets.only(bottom: 80),
          ///margin: EdgeInsets.only(bottom: 80),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: StreamBuilder<Map<int, Record>>(
            stream: _recordBloc.recordListStream,
            builder: (BuildContext context,
                AsyncSnapshot<Map<int, Record>> snapshot) {
              List<Record> taskList =
                  snapshot.hasData ? mapToList(snapshot.data!) : [];
              return ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  if (index == (taskList.length - 1)) {
                    return Column(
                      children: [
                        WidgetRecord(
                          record: taskList[index],
                          onSelected: onSelected,
                          onUnselected: onUnselected,
                          onTouch: onTouch,
                          editing: editing,
                        ),
                        Container(
                          height: 100,
                        )
                      ],
                    );
                  } else {
                    return WidgetRecord(
                      record: taskList[index],
                      onSelected: onSelected,
                      onUnselected: onUnselected,
                      onTouch: onTouch,
                      editing: editing,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
      //floatingActionButton: options(context),
    );
  }



  Widget options(BuildContext context) {
    if (isEditing()) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _selectedRecords.length < 2
            ? IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showDialogUpdate(context);
                },
              )
            : SizedBox(width: 2.0),
        SizedBox(
          height: 15,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _showDialogDelete(context);
          },
        ),
        SizedBox(
          height: 15,
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            _shareFiles();
          },
        ),
      ]);
    } else {
      return SizedBox(width: 2.0);
    }
  }

  void _showDialogDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            //title: Text(' '),
            content: Text("Delete selected records"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("cancel")),
              TextButton(
                onPressed: () {
                  _selectedRecords.forEach((k, r) {
                    _recordBloc.removeRecord.add(r);

                    //_taskBloc.removeTask.add(v); //remove on db
                    //widget.updateCard(); //update parent
                  });
                  //widget.updateCard(); //update parent
                  setState(() {
                    _selectedRecords.clear();
                    editing = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text("delete"),
              )
            ],
          );
        });
  }

  void _showDialogUpdate(BuildContext context) {
    late Record tempRecord;
    _selectedRecords.forEach((k, v) {
      tempRecord = v;
    });
    Record oldRecord = Record(
        id: tempRecord.id,
        filename: tempRecord.filename,
        samples: tempRecord.samples,
        date: tempRecord.date);
    String filename = tempRecord.filename.substring(0, (tempRecord.filename.length-4) ); // remove .csv

    ///suponiendo q solo hay un objeto
    final controllerEn = TextEditingController(text: filename);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Update"),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: controllerEn,
                      onChanged: (value) {
                        filename = value;
                      },
                      decoration: InputDecoration(labelText: "filename"),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Save"),
                onPressed: () {
                  tempRecord.filename = "$filename.csv";
                  _recordBloc.updateRecord.add(Pair<Record, Record>(
                      older: oldRecord, newer: tempRecord));
                  setState(() {
                    _selectedRecords.clear();
                    editing = false;
                  });
                  //widget.updateCard();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  ///functions
  List<Record> mapToList(Map<dynamic, Record> mapTasks) {
    List<Record> recordtList = [];
    List<Record> temp = [];
    if (mapTasks == null) {
      return temp;
    } else {
      mapTasks.forEach((key, value) {
        recordtList.add(value);
      });
      //read inverse, the uncompleted tasks at the end
      int numTasks = recordtList.length;
      for (int i = (numTasks - 1); i >= 0; i--) {
        temp.add(recordtList[i]);
      }

      return temp;
    }
  }

  void onTouch(Record record) {
    //_taskBloc.updateTask.add(task);
    //widget.updateCard();
  }

  void onSelected(Record record) {
    setState(() {
      _selectedRecords[record.id] = record;
      editing = true;
    });
    //_updateOptions();
  }

  void onUnselected(Record record) {
    setState(() {
      _selectedRecords.remove(record.id);
    });
    if (_selectedRecords.length <= 0) {
      setState(() {
        editing = false;
      });
    }
    //_updateOptions();
  }

  /*
  void _updateOptions(){
    print(">>>>>>>>>> set status lenDataSelected: ${_selectedTasks.length}");
    if(_selectedTasks.length<1){
      _recordBloc.changeStatusTabBar.add(StatusMenuTab.none);
    }
    if(_selectedTasks.length==1){
      _recordBloc.changeStatusTabBar.add(StatusMenuTab.options);
    }
    if(_selectedTasks.length>1){
      _recordBloc.changeStatusTabBar.add(StatusMenuTab.option);
    }
  }*/

  bool isEditing() {
    if (editing == null) {
      return false;
    }
    return editing;
  }

  void _shareFiles() async {
    Files files = Files();
    List<String> pathFiles = [];
    for (Record r in _selectedRecords.values) {
      File file = await files.getLocalFile(r);
      print(
          ">>>>>>>>>>>>>>>>>> filll List files paths ${file.path} | ${r.filename}");
      pathFiles.add(file.path);
    }
    print(">>>>>>>>>>>>>>>>>>ready to share files");
    Share.shareFiles(pathFiles, text: 'GSR records, signal and stress level');
  }
}
