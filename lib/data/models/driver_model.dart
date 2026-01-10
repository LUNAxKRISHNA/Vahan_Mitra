class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String licenseNumber;

  const Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['driverId'] ?? '',
      name: json['driverName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
    );
  }
}
