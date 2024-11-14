import 'dart:math';

double haversine(double lat1, double lon1, double lat2, double lon2) {
  const radius = 6371; // Earth's radius in km

  var lat1Rad = lat1 * pi / 180;
  var lon1Rad = lon1 * pi / 180;
  var lat2Rad = lat2 * pi / 180;
  var lon2Rad = lon2 * pi / 180;

  var dlat = lat2Rad - lat1Rad;
  var dlon = lon2Rad - lon1Rad;

  var a = sin(dlat / 2) * sin(dlat / 2) +
      cos(lat1Rad) * cos(lat2Rad) *
          sin(dlon / 2) * sin(dlon / 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return radius * c; // Distance in km
}
