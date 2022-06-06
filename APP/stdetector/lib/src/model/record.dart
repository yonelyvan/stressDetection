import 'package:sqflite/sqflite.dart';

class Record {

  static final String TABLE_NAME = "records"; // real
  int id;
  String filename;
  int samples;
  DateTime date;

  Record(
      {this.id = 0, this.filename = "", this.samples = 0, required this.date});

  void printRecord() {
    print(
        "RecordId: _id: $id, filename: $filename, samples: $samples, date: $date");
  }

  factory Record.fromMap(Map<dynamic, dynamic> map) {
    return Record(
        id: map["_id"],
        filename: map["filename"],
        samples: map["samples"],
        date: DateTime.fromMillisecondsSinceEpoch(map["date"]));
  }

  void createTable(Database db) {
    db.rawUpdate(
        "CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, filename VARCHAR(256), samples INTEGER, date INTEGER)");
  }

  // to insert sqlite
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "filename": filename,
      "samples": this.samples,
      "date": date.millisecondsSinceEpoch
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// load entity from JSON
  factory Record.fromJson(Map<dynamic, dynamic> json) {
    return Record(
        id: json["_id"],
        filename: json["filename"],
        samples: json["samples"],
        date: DateTime.fromMillisecondsSinceEpoch(json["date"]));
  }
}
