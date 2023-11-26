// like "API" between ui and db
import 'package:stdetector/src/repository/files.dart';
import 'package:stdetector/src/repository/record_controller.dart';

import '../../pair.dart';
import '../model/record.dart';

class Data {
  final Files _files = Files();
  final RecordController _recordController = RecordController();

  Data(){
    print("Created LoadData Class");
  }
  ///CRUDs


  Future<Record> insertNewRecord(Record record) async {
    print(">>>>>>>>>>>>>>>>>> on received: data");
    Record r = await _recordController.insert(record);
    r.printRecord();
    return r;
  }

  Future<int> removeRecord(Record record) async {
    // remove row on db
    int r = await _recordController.delete(record);
    // remove file on dist
    try {
      _files.delete(record: record);
    } catch (err) {
      print('Error: on delete file');
    }
    return r;
  }

  Future<int> updateTask(Pair<Record,Record> p) async {
    //update on db
    int r = await _recordController.update(p.newer);
    //update on disk
    try {
      _files.updateFileName(pairRecords: p);
    } catch (err) {
      print('Error: on delete file');
    }

    return r;
  }


  Future<Map<int, Record>> getMapRecord() async {
    print("###################### function: getMapRecord");
    List<Record> record = await _recordController.getList();
    print(">>>>>>>>>>>>>>> get map record>>>>>>>>>>>");
    Map<int, Record> recordsMap = Map<int, Record>();
    record.forEach((p) {
      recordsMap[p.id] = p;
    });
    return recordsMap;
  }


}
