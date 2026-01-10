class RouteData {
  final String id;
  final String name;
  final List<Stop> stops;

  const RouteData({required this.id, required this.name, required this.stops});

  factory RouteData.fromJson(Map<String, dynamic> json) {
    var rawStops = json['stops'] as List? ?? [];
    List<Stop> parsedStops = rawStops.map((s) => Stop.fromJson(s)).toList();

    return RouteData(
      id: json['routeId'] ?? '',
      name: json['routeName'] ?? '',
      stops: parsedStops,
    );
  }
}

class Stop {
  final String id;
  final String name;
  final String time;

  const Stop({required this.id, required this.name, required this.time});

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['stopId'] ?? '',
      name: json['stopName'] ?? '',
      time: json['arrivalTime'] ?? '',
    );
  }
}
