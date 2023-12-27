import 'dart:math';

const x_PI = 3.14159265358979324 * 3000.0 / 180.0;
const PI = 3.1415926535897932384626;
const a = 6378245.0;
const ee = 0.00669342162296594323;

/// 判断是否在国内，不在国内则不做偏移
/// @param {*} lng
/// @param {*} lat
bool outOfChina(double lng, double lat) {
  return (lng < 72.004 || lng > 137.8347) ||
      ((lat < 0.8293 || lat > 55.8271) || false);
}

/// 经度转换
/// @param { double } lng
/// @param { double } lat
double transformLat(double lng, double lat) {
  var ret = -100.0 +
      2.0 * lng +
      3.0 * lat +
      0.2 * lat * lat +
      0.1 * lng * lat +
      0.2 * sqrt(lng.abs());
  ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(lat * PI) + 40.0 * sin(lat / 3.0 * PI)) * 2.0 / 3.0;
  ret +=
      (160.0 * sin(lat / 12.0 * PI) + 320 * sin(lat * PI / 30.0)) * 2.0 / 3.0;
  return ret;
}

/// 纬度转换
/// @param { double } lng
/// @param { double } lat
double transformLng(double lng, double lat) {
  var ret = 300.0 +
      lng +
      2.0 * lat +
      0.1 * lng * lng +
      0.1 * lng * lat +
      0.1 * sqrt(lng.abs());
  ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(lng * PI) + 40.0 * sin(lng / 3.0 * PI)) * 2.0 / 3.0;
  ret +=
      (150.0 * sin(lng / 12.0 * PI) + 300.0 * sin(lng / 30.0 * PI)) * 2.0 / 3.0;
  return ret;
}

/// 百度坐标系 (BD-09) 与 火星坐标系 (GCJ-02)的转换 / 即百度转谷歌、高德
/// @param { double } bd_lon:需要转换的经纬
/// @param { double } bd_lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> bd09togcj02(double bdLon, double bdLat) {
  const xPi = 3.14159265358979324 * 3000.0 / 180.0;
  final x = bdLon - 0.0065;
  final y = bdLat - 0.006;
  final z = sqrt(x * x + y * y) - 0.00002 * sin(y * xPi);
  final theta = atan2(y, x) - 0.000003 * cos(x * xPi);
  final ggLng = z * cos(theta);
  final ggLat = z * sin(theta);
  return [ggLng, ggLat];
}

/// 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换 / 即谷歌、高德 转 百度
/// @param { double } lng:需要转换的经纬
/// @param { double } lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> gcj02tobd09(double lng, double lat) {
  var z = sqrt(lng * lng + lat * lat) + 0.00002 * sin(lat * x_PI);
  var theta = atan2(lat, lng) + 0.000003 * cos(lng * x_PI);
  var bdLng = z * cos(theta) + 0.0065;
  var bdLat = z * sin(theta) + 0.006;
  return [bdLng, bdLat];
}

/// WGS84坐标系转火星坐标系GCj02 / 即WGS84 转谷歌、高德
/// @param { double } lng:需要转换的经纬
/// @param { double } lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> wgs84togcj02(double lng, double lat) {
  if (outOfChina(lng, lat)) {
    return [lng, lat];
  } else {
    double dlat = transformLat(lng - 105.0, lat - 35.0);
    double dlng = transformLng(lng - 105.0, lat - 35.0);
    final radlat = lat / 180.0 * PI;
    double magic = sin(radlat);
    magic = 1 - ee * magic * magic;
    final sqrtmagic = sqrt(magic);
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
    dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * PI);
    final mglat = lat + dlat;
    final mglng = lng + dlng;
    return [mglng, mglat];
  }
}

/// GCJ02（火星坐标系） 转换为 WGS84 / 即谷歌高德转WGS84
/// @param { double } lng:需要转换的经纬
/// @param { double } lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> gcj02towgs84(double lng, double lat) {
  if (outOfChina(lng, lat)) {
    return [lng, lat];
  } else {
    double dlat = transformLat(lng - 105.0, lat - 35.0);
    double dlng = transformLng(lng - 105.0, lat - 35.0);
    double radlat = lat / 180.0 * PI;
    double magic = sin(radlat);
    magic = 1 - ee * magic * magic;
    double sqrtmagic = sqrt(magic);
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
    dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * PI);
    double mglat = lat + dlat;
    double mglng = lng + dlng;
    return [lng * 2 - mglng, lat * 2 - mglat];
  }
}

/// 百度坐标系转wgs84坐标系
/// @param { double } lng:需要转换的经纬
/// @param { double } lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> bd09towgs84(double lng, double lat) {
  // 百度坐标系先转为火星坐标系
  final gcj02 = bd09togcj02(lng, lat);
  // 火星坐标系转wgs84坐标系
  final result = gcj02towgs84(gcj02[0], gcj02[1]);
  return result;
}

/// wgs84坐标系转百度坐标系
/// @param { double } lng:需要转换的经纬
/// @param { double } lat:需要转换的纬度
/// @return { Array } result: 转换后的经纬度数组
List<double> wgs84tobd09(double lng, double lat) {
  // wgs84先转为火星坐标系
  final gcj02 = wgs84togcj02(lng, lat);
  // 火星坐标系转百度坐标系
  final result = gcj02tobd09(gcj02[0], gcj02[1]);
  return result;
}
