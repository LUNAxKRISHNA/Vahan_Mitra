import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<LocationData?> getUserLocation() async {
    if (await _checkPermission()) {
      return await _location.getLocation();
    }
    return null;
  }

  Stream<LocationData> getLocationStream() {
    // We could add permission check here too, but usually it's checked before subscribing
    return _location.onLocationChanged;
  }
}
