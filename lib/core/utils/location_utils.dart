import 'dart:math';

class LocationUtils {
  /// Calculates the distance between two coordinates in kilometers using the Haversine formula.
  static double calculateDistanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the earth in km
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double d = R * c; // Distance in km
    return d;
  }

  static double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
