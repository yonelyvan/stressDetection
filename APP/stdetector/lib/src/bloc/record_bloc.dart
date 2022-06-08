import 'dart:async';

import '../../pair.dart';
import '../model/record.dart';
import '../model/status_tab_bar.dart';
import '../repository/data.dart';


class RecordBloc {
  final Data data = Data();
  Map<int, Record> _recordMapList = {};
  StatusMenuTab _statusMenuTab = StatusMenuTab.none;

  /// stream controller CRUD
  final _recordListStreamController = StreamController<Map<int, Record>>.broadcast();

  final _addRecordStreamController = StreamController<Record>.broadcast();
  //final _readTasksStreamController = StreamController<Record>();
  final _updateRecordStreamController = StreamController<Pair<Record,Record>>.broadcast();
  final _removeRecordStreamController = StreamController<Record>.broadcast();
  //for status tab_bar
  final _statusBarStreamController = StreamController<StatusMenuTab>.broadcast();
  final _changeStatusTabBarStreamController = StreamController<StatusMenuTab>.broadcast();

  /// getters : Stream & sinks
  Stream<Map<int, Record>> get recordListStream => _recordListStreamController.stream;
  StreamSink<Map<int, Record>> get recordListSink => _recordListStreamController.sink;

  StreamSink<Record> get addRecord => _addRecordStreamController.sink;
  StreamSink<Pair<Record,Record>> get updateRecord => _updateRecordStreamController.sink;
  StreamSink<Record> get removeRecord => _removeRecordStreamController.sink;
  //for status tab_bar
  Stream<StatusMenuTab> get statusBarStream => _statusBarStreamController.stream;//for ui
  StreamSink<StatusMenuTab> get statusBarSink => _statusBarStreamController.sink;//for ui

  StreamSink<StatusMenuTab> get changeStatusTabBar => _changeStatusTabBarStreamController.sink;
  //StreamSink<StatusMenuTab> get statusBarSink => _addStatusTabBarStreamController.sink;


  /// construct set listeners for changes
  RecordBloc() {
    //push data
    recordListSink.add(_recordMapList);
    _readRecord();
    //push status tab init
    _statusBarStreamController.add(_statusMenuTab);

    //listen for changes
    _addRecordStreamController.stream.listen(_addRecord);
    //_readTasksStreamController.stream.listen(_readRecord);
    _updateRecordStreamController.stream.listen(_updateRecord);
    _removeRecordStreamController.stream.listen(_removeRecord);
    //for status tab bar
    _changeStatusTabBarStreamController.stream.listen(_changeStatus);
  }

  /// call functions
  _addRecord(Record record) {
    print(">>>>>>>>>>>>>>>>>>>>>>>>> on received: record_bloc");
    data.insertNewRecord(record).then((r) {
      _recordMapList[r.id] = r;
      recordListSink.add(_recordMapList);
    });
  }

  _readRecord() {
    data.getMapRecord().then((projects) {
      _recordMapList = projects;
      _recordListStreamController.add(_recordMapList);
    });
  }

  /*
  _readRecords() {
    data.getMapRecords().then((r) {
      _taskMapList = r;
      //_taskListStreamController.add(_taskMapList);
      recordListSink.add(_taskMapList);
    });
  }*/

  _updateRecord(Pair<Record,Record> p) {
    data.updateTask(p).then((value) {
      if (value >= 1) {
        _recordMapList[p.older.id] = p.newer;
        recordListSink.add(_recordMapList);
      }
      ///TODO: show message of error on update
    });
  }

  _removeRecord(Record record) {
    data.removeRecord(record).then((value) {
      if (value >= 1) {
        _recordMapList.remove(record.id);
        recordListSink.add(_recordMapList);
      }
      ///TODO: show message of error on remove
    });
    
  }

  //for status tab bar
  _changeStatus(StatusMenuTab newStatus){
    print(">>>>>>>>>>>>>>>>>>>>>>>>> on received status Bar: record_bloc");
    _statusMenuTab = newStatus;
    //statusBarSink.add(_statusMenuTab);
    _statusBarStreamController.add(_statusMenuTab);
    print(">>>>>>>>>>>>>>>>>>>>>>>>> updates status Bar: $_statusMenuTab");
  }



  ///dispose *
  void dispose() {
    _recordListStreamController.close();
    _addRecordStreamController.close();
    //_readTasksStreamController.close();
    _updateRecordStreamController.close();
    _removeRecordStreamController.close();

    //for tab bar screen
    _statusBarStreamController.close();
    _changeStatusTabBarStreamController.close();
  }
}
