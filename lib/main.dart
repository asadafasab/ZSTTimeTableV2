import 'package:flutter/material.dart';
import 'timeTable.dart';
import 'date.dart';
import 'timeTableWebView.dart';
import 'package:ZSTPlan/dbhelper.dart';
import 'history.dart';
import 'package:ZSTPlan/settings.dart';
import 'package:ZSTPlan/timeTableUI.dart';

String _gettheme;
DBHelper _dbh = DBHelper();

void main() async {
  Brightness brightness;

  _gettheme = await _dbh.getSettings("theme");
  if (_gettheme == "light") {
    brightness = Brightness.light;
  } else {
    brightness = Brightness.dark;
  }

  _theme() {
    return ThemeData(
      primaryColor: const Color(0xff005b96),
      accentColor: const Color(0xff851e3e),
      brightness: brightness,
    );
  }

  runApp(MaterialApp(
    theme: _theme(),
    home: _HomePage(),
  ));
}

class _HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String date;
  String _loading = "Ładowanie...";
  List<String> _datesFromDB = [];
  List<History> _historyList = [];
  bool _noConnection = false;
  bool _webView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ZST Turek"),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () {
              if (_datesFromDB != null && _datesFromDB.length > 0)
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                          title: Text('Wybierz date'),
                          children: <Widget>[
                            ListTile(
                              title: Text(_datesFromDB[0].replaceAll("/", "")),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setDateText(0);
                              },
                            ),
                            ListTile(
                              title: Text(_datesFromDB[1].replaceAll("/", "")),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setDateText(1);
                              },
                            ),
                            ListTile(
                              title: Text(_datesFromDB[2].replaceAll("/", "")),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setDateText(2);
                              },
                            ),
                          ]);
                    });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (int i) {
            var str = "";
            if (i == 0) {
              str = "oddzialy";
            } else if (i == 1) {
              str = "nauczyciele";
            } else if (i == 2) {
              str = "sale";
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TimeTableListPage(str, date, _webView)));
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.class_,
                ),
                title: Text("Klasy")),
            BottomNavigationBarItem(
                icon: Icon(Icons.perm_identity), title: Text("Nauczyciele")),
            BottomNavigationBarItem(
                icon: Icon(Icons.store), title: Text("Sale")),
          ]),
      body: _historyList.length == 0 ? _empty() : _body(),
    );
  }

  Widget _empty() {
    return Column(
      children: <Widget>[
        _noConnection == true
            ? FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.error),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                    ),
                    Text("Błąd połączenia...")
                  ],
                ),
                onPressed: () {
                  _getHistory();
                },
              )
            : Center(
                child: Text(
                  _loading,
                  style: TextStyle(fontSize: 18.0),
                ),
              )
      ],
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        _noConnection == true
            ? FlatButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.error),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                    ),
                    Text("Błąd połączenia...")
                  ],
                ),
                onPressed: () {
                  _getHistory();
                },
              )
            : Text(
                "Wybrana data: $date",
                style: TextStyle(fontSize: 17.0),
              ),
        Expanded(
          child: ListView.builder(
              itemCount: _historyList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      _historyList[index].toMap()["name"],
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      if (_webView) {
                        ShowTimeTable(_historyList[index].toMap()["url"], date);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeTableUI(
                                    _historyList[index].toMap()["url"], date)));
                      }
                    },
                    onLongPress: () {
                      return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Usunąć?'),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('Nie'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                FlatButton(
                                  child: Text('Tak'),
                                  onPressed: () {
                                    _dbh.deleteHistoryItem(
                                        _historyList[index].toMap()["name"]);
                                    _historyList.removeAt(index);
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                );
              }),
        )
      ],
    );
  }

  _setDateText(int index) {
    setState(() {
      date = _datesFromDB[index];
      _dbh.saveSettings({"k": "defaultDate", "v": date});
    });
  }

  _getHistory() async {
    _noConnection = false;
    _historyList = await _dbh.getHistory();
    await LoadDate().getData().catchError((e) {
      _noConnection = true;
    });
    _datesFromDB = await _dbh.getDates();
    date = await _dbh.getSettings("defaultDate");
    if (date == "light") date = _datesFromDB[0];

    _loading = "Brak historii";
    if (await _dbh.getSettings("webview") == "enable") _webView = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this._getHistory();
  }
}
