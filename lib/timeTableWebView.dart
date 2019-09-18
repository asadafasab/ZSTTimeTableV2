import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ShowTimeTable {
  final String classUrl;
  final String baseUrl = "https://www.zst.net.pl/pliki/plany/";
  final String date;

  ShowTimeTable(this.classUrl, this.date) {
    launchTimeTable('$baseUrl$date$classUrl');
  }

  Future launchTimeTable(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      print("error... $url");
    }
  }
}
