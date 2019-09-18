import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:ZSTPlan/history.dart';
import 'package:ZSTPlan/timeTableData.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();
  factory DBHelper() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DBHelper.internal();

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE History(id INTEGER PRIMARY KEY,name TEXT, url TEXT,UNIQUE(name,url))");
    await db.execute("CREATE TABLE Dates(id INTEGER PRIMARY KEY, date TEXT)");
    await db.execute(
        "CREATE TABLE Settings(id INTEGER PRIMARY KEY, k TEXT ,v TEXT)");
  }

  Future saveHistoryItem(History h) async {
    var dbClient = await db;
    await dbClient.rawInsert(
        "INSERT OR IGNORE INTO History(name,url) values(?,?)", [h.name, h.url]);
  }

  Future<List<History>> getHistory() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM History');
    List<History> h = new List();
    for (int i = 0; i < list.length; i++) {
      var tmp = History(name: list[i]["name"], url: list[i]["url"]);
      h.add(tmp);
    }
    return h;
  }

  Future deleteHistoryItem(String h) async {
    var dbClient = await db;
    await dbClient.rawDelete('DELETE FROM History WHERE name = ?', [h]);
  }

  //timetable
  Future saveTimeTable(TimeTable tt, String name) async {
    name = name.replaceFirst(".html", "").replaceFirst("plany/", "");

    var dbClient = await db;
    await dbClient.execute(
        "CREATE TABLE IF NOT EXISTS $name (id INTEGER PRIMARY KEY, "
        "monday TEXT,tuesday TEXT,wednesday TEXT, thursday TEXT, friday TEXT)");

    await dbClient.rawQuery(
        "insert or replace into $name (id,monday,tuesday,wednesday,thursday,friday)"
        "values (?,?,?,?,?,?);",
        [tt.id, tt.monday, tt.tuesday, tt.wednesday, tt.thursday, tt.friday]);
  }

  Future<List<Map>> getTimeTable(String name) async {
    name = name.replaceFirst(".html", "").replaceFirst("plany/", "");
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM $name");
    return list;
  }

  //date
  Future saveDate(dynamic d) async {
    var dbClient = await db;
    await dbClient.rawQuery(
        "insert or replace into Dates(id,date)"
        "values (?,?);",
        [d["i"], d["date"]]);
  }

  Future<List<String>> getDates() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Dates');
    List<String> d = new List();
    for (int i = 0; i < list.length; i++) {
      d.add(list[i]["date"]);
    }
    return d;
  }

  //settings
  Future saveSettings(dynamic d) async {
    var dbClient = await db;
    await dbClient.rawQuery(
        "insert or replace into Settings(id,k,v)"
        "values ("
        "(select id from Settings where k='${d["k"]}'),?,?);",
        [d["k"], d["v"]]);
  }

  Future<String> getSettings(String k) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Settings where k="$k"');
    if (list.length != 0) {
      String d = list[0]["v"];
      return d;
    }
    return "light";
  }
}
