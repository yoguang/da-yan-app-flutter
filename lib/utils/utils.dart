import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// 根据两个定位的经纬度计算距离
Future<double> calculateDistance(
    double lat1, double lon1, double lat2, double lon2) async {
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
  // distance.toStringAsFixed(2) 保留两位小数四舍五入
  debugPrint('两点之间的距离：${distance.toStringAsFixed(2)} km');
  debugPrint('两点之间的距离：$distance km');
  return distance;
}
