import 'package:flutter/widgets.dart';
import '../utils/local_storage.dart';

final localStorage = LocalStorage();

class LocationModel extends ChangeNotifier {
  LocationModel({
    this.description,
    this.adCode,
    this.city,
    this.cityCode,
    this.country,
    this.district,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.streetNumber,
    this.province,
    this.street,
    this.locationType,
    this.locationTime,
    this.speed,
    this.altitude,
    this.accuracy,
    this.bearing,
  });

  void fromMap(Map<String, dynamic> map) {
    locationTime = map["locationTime"] as String?;
    latitude = numberStringToDouble(map["latitude"]) as double?;
    longitude = numberStringToDouble(map["longitude"]) as double?;
    country = map["country"] as String?;
    province = map["province"] as String?;
    city = map["city"] as String?;
    street = map["street"] as String?;
    streetNumber = map["streetNumber"] as String?;
    cityCode = map["cityCode"] as String?;
    adCode = map["adCode"] as String?;
    formattedAddress = map["address"] as String?;
    description = map["description"] as String?;
    locationType = map["locationType"] as int?;
    accuracy = numberStringToDouble(map["accuracy"]) as double?;
    altitude = numberStringToDouble(map["altitude"]) as double?;
    district = map["district"] as String?;
    speed = numberStringToDouble(map["speed"]) as double?;
    bearing = numberStringToDouble(map["bearing"]) as double?;
    notifyListeners();

    /// 定位保存到本地
    localStorage.set('location', toMap());
  }

  late String? formattedAddress;
  late String? country;
  late String? province;
  late String? city;
  late String? district;
  late String? cityCode;
  late String? adCode;
  late String? street;
  late String? streetNumber;
  late String? locationTime;

  late double? speed;
  late double? altitude;
  late double? latitude;
  late double? longitude;
  late double? accuracy;
  late double? bearing;

  ///  地址简述
  late String? description;

  late int? locationType;

  Map<String, dynamic> toMap() => {}..addAll({
      "locationTime": locationTime,
      "latitude": latitude,
      "longitude": longitude,
      "country": country,
      "province": province,
      "city": city,
      "district": district,
      "street": street,
      "streetNumber": streetNumber,
      "cityCode": cityCode,
      "adCode": adCode,
      "formattedAddress": formattedAddress,
      "description": description,
      "locationType": locationType,
      "accuracy": accuracy,
      "altitude": altitude,
      "bearing": bearing,
      "speed": speed,
    });

  @override
  String toString() {
    return toMap().toString();
  }

  static numberStringToDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return double.parse(value);
    }
    return value;
  }
}
