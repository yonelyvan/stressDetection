import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../model/record.dart';

///CRUD acciones sobre la base de datos
class RecordController {
  static final String DB_FILE_NAME = "records01.db"; // test

  static final RecordController _instance = RecordController._internal();
  factory RecordController() => _instance;
  RecordController._internal();

  static Future<Database> _openDB() async {
    String databasesPath = await getDatabasesPath();
    String path = "$databasesPath/$DB_FILE_NAME";
    return openDatabase(path, version: 1, onCreate: (database, version) {
      Record(date: DateTime.now()).createTable(database); //TODO refactorizar a un solo archivo
    });
  }

  ///CRUD
  ///select
  Future<List<Record>> getList() async {
    Database? dbClient = await _openDB();
    try {
      List<Map> maps = await dbClient
          .query(Record.TABLE_NAME, columns: ["_id", "filename", "samples", "date"]);
      List<Record> r = maps.map((i) => Record.fromMap(i)).toList();
      print(">>>>>>>>>>>>>>>>>>>>>begin data>>>>>>>>>>>>");
      r.forEach((element) {
        element.printRecord();
      });
      print(">>>>>>>>>>>>>>>>>>>>> end data>>>>>>>>>>>>");
      return r; //lista de objetos
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  ///insert
  Future<Record> insert(Record record) async {
    var dbClient = await _openDB();
    record.id = await dbClient.insert(
      Record.TABLE_NAME,
      record.toMap(),
    );
    return record;
  }

  ///delete
  Future<int> delete(Record element) async {
    var dbClient = await _openDB();
    return await dbClient
        .delete(Record.TABLE_NAME, where: '_id = ?', whereArgs: [element.id]);
  }

  ///update
  Future<int> update(Record element) async {
    var dbClient = await _openDB();

    return await dbClient.update(Record.TABLE_NAME, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}
