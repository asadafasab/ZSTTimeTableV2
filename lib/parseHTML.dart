import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ZSTPlan/dbhelper.dart';
import 'package:ZSTPlan/timeTableData.dart';

class ParseTimeTable {
  final String url = "http://www.zst.net.pl/pliki/plany/";
  final String date;
  final String target;

  ParseTimeTable(this.date, this.target);

  Future getData() async {
    http.Response html =
        await http.get(url + date + target, headers: {'Content-Type': 'html'});
    String body = utf8.decode(html.bodyBytes).replaceAll("<br>", "\n");
    var dbh = DBHelper();
    List<TimeTable> _tt = [];
    int lesson = 0;

    List<dom.Element> parsed = parse(body).querySelectorAll(".l");
    int i = 0;
    while (i < parsed.length) {
      _tt.add(TimeTable(
          id: lesson,
          monday: parsed[i].text,
          tuesday: parsed[i + 1].text,
          wednesday: parsed[i + 2].text,
          thursday: parsed[i + 3].text,
          friday: parsed[i + 4].text));
      i += 5;
      lesson++;
    }
    _tt.forEach((t) {
      dbh.saveTimeTable(t, target);
    });
  }
}
