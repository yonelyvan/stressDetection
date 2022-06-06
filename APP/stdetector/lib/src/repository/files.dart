import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../pair.dart';
import '../model/record.dart';

class Files{
  Files(){
    print("hello files");
  }

  /// CRUD files
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getLocalFile(Record record) async {
    final path = await _localPath;
    return File('$path/${record.filename}');
  }

  /// Create
  Future<File> writeSignal({required List<int> signal, required Record record}) async {
    String str = getDataGSR(signal);
    final file = await getLocalFile(record);
    return file.writeAsString(str);
  }

  /// Read
  Future<List<int>> readCounter({required Record record}) async {
    List<int> l =[];
    try {
      final file = await getLocalFile(record);
      final contents = await file.readAsString();
      print(">>>>>>>>>>>>>>>>>>contents");
      print(contents);
      ///TODO: parse list
      //return int.parse(contents);
      return l;
    } catch (e) {
      return l;
    }
  }

  /// Update
  Future<void> updateFileName({required Pair<Record,Record> pairRecords}) async {
    final file = await getLocalFile(pairRecords.older);
    print(">>>>>>>older name>>>>>>>>> ${file.path}");
    print(">>>>>>>newer name>>>>>>>>> ${pairRecords.newer.filename}");

    final path = await _localPath;
    String newPath = '$path/${pairRecords.newer.filename}';
    await file.rename(newPath);
  }

  // Delete
  Future<void> delete({required Record record}) async {
    final file = await getLocalFile(record);
    await file.delete(recursive: false);
  }



  /// CSV files
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

  /// share
  void _shareFile() async {
    print("_shareFile");
    //final file = await _localFile;
    //Share.shareFiles([file.path], text: 'Archivo prueba');
  }


}