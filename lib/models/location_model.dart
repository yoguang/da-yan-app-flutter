import 'package:flutter/widgets.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

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
  });

  void fromMap(Map<String, dynamic> map) {
    latitude = map['latitude'] as double?;
    longitude = map['longitude'] as double?;
    locationTime = map['locationTime'] as String?;
    speed = map['speed'] as double?;
    altitude = map['altitude'] as double?;
    accuracy = map['accuracy'] as double?;
    city = map['city'] as String?;
    cityCode = map['cityCode'] as String?;
    country = map['country'] as String?;
    district = map['district'] as String?;
    province = map['province'] as String?;
    street = map['street'] as String?;
    streetNumber = map['streetNumber'] as String?;
    locationType = map['locationType'] as int?;
    formattedAddress = map['address'] as String?;
    description = map['description'] as String?;
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
  late String? streetNumber;
  late String? locationTime;

  late double? speed;
  late double? altitude;
  late double? latitude;
  late double? longitude;
  late double? accuracy;

  ///  地址简述
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
      'streetNumber': streetNumber,
      'province': province,
      'street': street,
      'locationType': locationType,
    });
}
