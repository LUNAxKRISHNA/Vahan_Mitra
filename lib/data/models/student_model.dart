class Student {
  final String id;
  final String name;
  final String assignedRouteId;
  final String assignedStop;
  final String paymentStatus;

  const Student({
    required this.id,
    required this.name,
    required this.assignedRouteId,
    required this.assignedStop,
    required this.paymentStatus,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['studentId'] ?? '',
      name: json['studentName'] ?? '',
      assignedRouteId: json['assignedRouteId'] ?? '',
      assignedStop: json['assignedStop'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'Unpaid',
    );
  }
}
