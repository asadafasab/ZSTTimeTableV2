import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ZSTPlan/timeTableWebView.dart';
import 'package:ZSTPlan/dbhelper.dart';
import 'package:ZSTPlan/history.dart';
import 'package:ZSTPlan/timeTableUI.dart';

class TimeTableListPage extends StatefulWidget {
  final String _str;
  final String _date;
  final bool _webView;
  TimeTableListPage(this._str, this._date, this._webView);
  @override
  TimeTableList createState() =>
      TimeTableList(this._str, this._date, this._webView);
}

class TimeTableList extends State<TimeTableListPage> {
  var _searchView = TextEditingController();
  bool _firstSearch = true;
  bool _loading = true;
  String _query = "";
  final String _typeOfList;
  final String _date;
  final bool _webView;
  String _url;
  List<Classes> _data;
  List<Classes> _filteredData;

  TimeTableList(this._typeOfList, this._date, this._webView) {
    _url = "https://www.zst.net.pl/pliki/plany/$_date/lista.html";
    _searchView.addListener(() {
      if (_searchView.text.isEmpty) {
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchView.text;
        });
      }
    });
  }

  Future getTimeTableList() async {
    dom.Document document;
    var html =
        await http.get(_url, headers: {'Content-Type': 'html'});
    String body = utf8.decode(html.bodyBytes);
    document = parse(body);
    setState(() {
      _data = document
          .getElementById(_typeOfList)
          .getElementsByTagName("a")
          .map((d) => Classes(d.text, d.attributes.values.first))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text(this._typeOfList == "oddzialy" ? "Klasy" : this._typeOfList),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              _createSearchView(),
              _loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _firstSearch ? _createListView() : _performSearch()
            ],
          ),
        ));
  }

  Widget _createSearchView() {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: TextField(
        controller: _searchView,
        decoration: InputDecoration(
          hintText: "Search or something...",
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _performSearch() {
    _filteredData = List<Classes>();
    for (int i = 0; i < _data.length; ++i) {
      var item = _data[i];
      if (item._name.toLowerCase().contains(_query.toLowerCase())) {
        _filteredData.add(item);
      }
    }
    return _createFilteredListView();
  }

  Widget _createListView() {
    return Flexible(
      child: ListView.builder(
        itemCount: _data == null ? 0 : _data.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: FlatButton(
              onPressed: () {
                _saveHistory(_data[index]._name, _data[index]._url);
                if (_webView) {
                  ShowTimeTable(_data[index]._url, _date);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TimeTableUI(_data[index]._url, _date)));
                }
              },
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Text(_data[index]._name[0]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                  ),
                  Text(_data[index]._name)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _createFilteredListView() {
    return Flexible(
      child: ListView.builder(
        itemCount: _filteredData == null ? 0 : _filteredData.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: FlatButton(
              onPressed: () {
                _saveHistory(
                    _filteredData[index]._name, _filteredData[index]._url);
                if (_webView) {
                  ShowTimeTable(_data[index]._url, _date);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TimeTableUI(_data[index]._url, _date)));
                }
              },
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Text(_filteredData[index]._name[0]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                  ),
                  Text(_filteredData[index]._name)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _saveHistory(String _name, String _url) async {
    DBHelper().saveHistoryItem(History(name: _name, url: _url));
  }

  @override
  void initState() {
    super.initState();
    this.getTimeTableList();
  }
}

class Classes {
  String _name;
  String _url;
  Classes(this._name, this._url);

  @override
  String toString() => '$_name $_url';
}
