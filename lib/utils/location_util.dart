import 'dart:math';

// 根据两个定位的经纬度计算距离
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  double pi = 3.141592653589793;
  // 将经纬度转换为弧度
  lat1 = lat1 * (pi / 180);
  lon1 = lon1 * (pi / 180);
  lat2 = lat2 * (pi / 180);
  lon2 = lon2 * (pi / 180);

  // 使用Haversine公式计算距离
  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = 6371 * c; // 地球半径为6371km
  return distance;
}

// 格式化距离
Map<String, dynamic> formattedDistance(latLng1, latLng2) {
  if (latLng1 == null ||
      latLng1['latitude'] == null ||
      latLng1['longitude'] == null) return {'value': 0, 'text': ''};
  if (latLng2 == null ||
      latLng2['latitude'] == null ||
      latLng2['longitude'] == null) return {'value': 0, 'text': ''};
  final distanceNum = calculateDistance(latLng1['latitude'],
      latLng1['longitude'], latLng2['latitude'], latLng2['longitude']);
  // 小于1米显示在你身边
  if (distanceNum < 0.001) {
    return {'value': distanceNum, 'text': '在你身边'};
  }
  // 小于10米显示附近
  if (distanceNum < 0.01) {
    return {'value': distanceNum, 'text': '附近'};
  }
  // 小于0.1公里显示多少米
  if (distanceNum < 0.1) {
    return {
      'value': distanceNum,
      'text': '${(distanceNum * 1000).toStringAsFixed(2)}米'
    };
  }
  return {'value': distanceNum, 'text': '${distanceNum.toStringAsFixed(2)}公里'};
}
