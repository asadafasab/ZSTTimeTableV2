class TimeTable {
  int id;
  String monday;
  String tuesday;
  String wednesday;
  String thursday;
  String friday;

  TimeTable(
      {this.id,
      this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday});

  factory TimeTable.fromMap(Map<String, dynamic> map) => TimeTable(
        id: map["id"],
        monday: map["monday"],
        tuesday: map["tuesday"],
        wednesday: map["wednesday"],
        thursday: map["thursday"],
        friday: map["friday"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thursday": thursday,
        "friday": friday
      };
}
