import 'package:flutter/material.dart';
import 'package:ZSTPlan/dbhelper.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String theme;
  bool _webView = false;
  DBHelper _dbh = DBHelper();

  SettingsPageState() {
    getFromDB();
  }
  getFromDB() async {
    theme = await _dbh.getSettings("theme");
    if (await _dbh.getSettings("webview") == "enable")
      _webView = true;
    else
      _webView = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ustawienia"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.text_fields),
              title: Text("Zmien wyglad..."),
              onTap: () {
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Zmienić wygląd?'),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('Nie'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          FlatButton(
                            child: Text('Tak'),
                            onPressed: () {
                              if (theme == "dark")
                                _dbh.saveSettings({"k": "theme", "v": "light"});
                              else
                                _dbh.saveSettings({"k": "theme", "v": "dark"});
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
            SwitchListTile(
              value: _webView,
              title: Text(
                'Widok HTML',
              ),
              secondary: const Icon(Icons.web),
              onChanged: (t) {
                _webView = !_webView;
                _webView
                    ? _dbh.saveSettings({"k": "webview", "v": "enable"})
                    : _dbh.saveSettings({"k": "webview", "v": "disable"});
              },
            ),
            ListTile(
              leading: Icon(Icons.open_in_browser),
              title: Text("Github repo"),
              onTap: () {
                _launchURL("https://github.com/t0p00/ZSTTimeTable");
              },
              onLongPress: () {
                if (theme == "dark") _launchURL("https://youtu.be/ZZ5LpwO-An4");
              },
            ),
            ListTile(
              leading: Icon(Icons.pageview),
              title: Text('strona "ZST Turek"'),
              onTap: () {
                _launchURL("https://zst.net.pl/");
              },
            ),
            ListTile(
              title: Text(
                  '\nTips:\n\n- Aby usunąć element z historii należy go przytrzymać'
                  ' i kliknąć "Tak" na "pop-up"\n\n'
                  '- Data planu jest wczytywana z linku nie z tekstu wyświetlanego na stronie\n\n'
                  '- Ustawienia beda odczowalne dopiero po restarcie'),
              leading: Icon(Icons.info),
            )
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Nope nope $url";
    }
  }
}
