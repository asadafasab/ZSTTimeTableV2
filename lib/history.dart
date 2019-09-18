class History {
  String name;
  String url;

  History({this.name, this.url});

  factory History.fromMap(Map<String, dynamic> map) => History(
        name: map["name"],
        url: map["url"],
      );

  Map<String, dynamic> toMap() => {"name": name, "url": url};
}
