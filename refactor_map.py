import re
import os

filepath = r'd:\Works\Vahan_Mitra\lib\ui\screens\map_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace imports
content = re.sub(r"import 'package:flutter_map/flutter_map.dart';\n", "import 'package:google_maps_flutter/google_maps_flutter.dart';\n", content)
content = re.sub(r"import 'package:latlong2/latlong.dart';\n", "", content)

# MapController to GoogleMapController
content = re.sub(r"final MapController _mapController = MapController\(\);", "GoogleMapController? _mapController;", content)
content = re.sub(r"_mapController\.dispose\(\);", "_mapController?.dispose();", content)

# _mapController.move(loc, zoom) to _mapController.animateCamera(CameraUpdate.newLatLngZoom(loc, zoom))
content = re.sub(r"_mapController\.move\(([^,]+),\s*([^\)]+)\)\;", r"_mapController?.animateCamera(CameraUpdate.newLatLngZoom(\1, \2));", content)

# southIndiaBounds
content = re.sub(r"final southIndiaBounds = LatLngBounds\(\s*const LatLng\(([^,]+),\s*([^\)]+)\),\s*// South-West\s*const LatLng\(([^,]+),\s*([^\)]+)\),\s*// North-East\s*\);", r"final southIndiaBounds = LatLngBounds(southwest: const LatLng(\1, \2), northeast: const LatLng(\3, \4));", content)

# Remove mapTilerKey and tileUrl
content = re.sub(r"const mapTilerKey = String\.fromEnvironment\([\s\S]*?\);\n", "", content)
content = re.sub(r"final tileUrl =[\s\S]*?;\n", "", content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
