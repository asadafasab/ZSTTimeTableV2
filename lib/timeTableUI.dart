import 'package:flutter/material.dart';
import 'package:ZSTPlan/parseHTML.dart';
import 'package:ZSTPlan/dbhelper.dart';

class TimeTableUI extends StatefulWidget {
  final String classUrl;
  final String date;

  TimeTableUI(this.classUrl, this.date);

  TimeTableUIState createState() => TimeTableUIState(this.date, this.classUrl);
}

class TimeTableUIState extends State<TimeTableUI>
    with SingleTickerProviderStateMixin {
  final String classUrl;
  final String date;
  DBHelper _dbh = DBHelper();
  List<Map> _tt = [];
  TabController _tabController;
  List hours = [
    "8:00\n8:45  ",
    "8:55\n9:40  ",
    "9:50\n10:35  ",
    "10:45\n11:30  ",
    "11:40\n12:25  ",
    "12:40\n13:25  ",
    "13:35\n14:20  ",
    "14:25\n15:10  ",
    "15:15\n16:00  "
  ];

  TimeTableUIState(this.date, this.classUrl);

  @override
  initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
    initDB();
  }
  //TODO: granatowy

  initDB() async {
    await ParseTimeTable(date, classUrl).getData();
    await Future.delayed(Duration(seconds: 2));
    _tt = await _dbh.getTimeTable(classUrl);
    setState(() {
      _tabController.animateTo(getDay());
    });
  }

  int getDay() {
    int day = DateTime.now().weekday;
    --day;
    if (day >= 5 || day < 0) day = 0;
    return day;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(text: "PN"),
              Tab(text: "WT"),
              Tab(text: "SR"),
              Tab(text: "CZW"),
              Tab(text: "PT"),
            ],
          ),
          title: Text("Plan Lekcji"),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            createList("monday"),
            createList("tuesday"),
            createList("wednesday"),
            createList("thursday"),
            createList("friday"),
          ],
        ),
      ),
    );
  }

  Widget createList(String day) {
    return _tt.length == 0
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            child: ListView.builder(
            itemCount: _tt.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10.0)),
                    CircleAvatar(
                      child: Text("${index + 1}"),
                      minRadius: 22.0,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          _tt[index][day],
                          style: TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                    ),
                    Text(hours[index]),
                  ],
                ),
              );
            },
          ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
