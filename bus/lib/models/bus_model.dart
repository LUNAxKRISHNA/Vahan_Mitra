class Bus {
  final String id;
  final String route;
  final String status;
  final String nextStop;
  final int eta;
  final int fullness;
  final bool hasWifi;
  final bool hasCharging;

  const Bus({
    required this.id,
    required this.route,
    required this.status,
    required this.nextStop,
    required this.eta,
    required this.fullness,
    this.hasWifi = true,
    this.hasCharging = false,
  });
}