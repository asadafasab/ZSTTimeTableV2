import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ZSTPlan/dbhelper.dart';

class LoadDate {
  final String url = "http://zst.net.pl/index.php/plan-lekcji";

  Future getData() async {
    var res = await http.read(url);

    var index = 1;
    var dbh = DBHelper();

    parse(res).querySelectorAll("span").forEach((dom.Element q) {
      if (q.text.contains("Plan lekcji od")) {
        if (index < 4) {
          var tmp = q.querySelector("a").attributes['href'].substring(34, 45);
          dbh.saveDate({"date": tmp, "i": index});
        }
        index++;
      }
    });
  }
}
