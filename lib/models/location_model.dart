import 'package:flutter/widgets.dart';

class LatLng {
  const LatLng(this.latitude, this.longitude);

  LatLng.fromMap(Map<dynamic, dynamic> map)
      : latitude = map['latitude'] as double?,
        longitude = map['longitude'] as double?;

  final double? latitude;
  final double? longitude;

  Map<String, double?> toMap() =>
      {'latitude': latitude, 'longitude': longitude};
}

class LocationModel extends ChangeNotifier {
  LocationModel({
    this.description,
    this.code,
    this.adCode,
    this.aoiName,
    this.city,
    this.cityCode,
    this.country,
    this.district,
    this.latLng,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.number,
    this.poiName,
    this.province,
    this.street,
    this.locationType,
    this.timestamp,
    this.speed,
    this.altitude,
    this.accuracy,
    this.provider,
  });

  void fromMap(Map<String, dynamic> map) {
    description = map['description'] as String?;
    code = map['code'] as int?;
    latLng = LatLng.fromMap(map['latLng']);
    latitude = map['latLng']['latitude'] as double?;
    longitude = map['latLng']['longitude'] as double?;
    timestamp = map['timestamp'] as double?;
    speed = map['speed'] as double?;
    altitude = map['altitude'] as double?;
    accuracy = map['accuracy'] as double?;
    adCode = map['adCode'] as String?;
    aoiName = map['aoiName'] as String?;
    city = map['city'] as String?;
    cityCode = map['cityCode'] as String?;
    country = map['country'] as String?;
    district = map['district'] as String?;
    formattedAddress = map['formattedAddress'] as String?;
    number = map['number'] as String?;
    poiName = map['poiName'] as String?;
    provider = map['provider'] as String?;
    province = map['province'] as String?;
    street = map['street'] as String?;
    locationType = map['locationType'] as int?;
    notifyListeners();
  }

  late String? formattedAddress;
  late String? country;
  late String? province;
  late String? city;
  late String? district;
  late String? cityCode;
  late String? adCode;
  late String? street;
  late String? number;
  late String? poiName;
  late String? aoiName;

  late double? timestamp;
  late double? speed;
  late double? altitude;
  late double? latitude;
  late double? longitude;
  late double? accuracy;
  late String? provider;

  // 默认定位北京
  late LatLng? latLng = const LatLng(39.909187, 116.397451);

  late int? code;

  ///  描述
  late String? description;

  late int? locationType;

  Map<String, dynamic> toMap() => {}..addAll({
      'adCode': adCode,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'cityCode': cityCode,
      'country': country,
      'district': district,
      'formattedAddress': formattedAddress,
      'number': number,
      'province': province,
      'street': street,
      'locationType': locationType,
    });
}
