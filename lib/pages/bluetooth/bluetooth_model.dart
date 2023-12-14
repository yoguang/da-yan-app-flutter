import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class LocalBluetoothDevice extends BluetoothDevice {
  late String? address;
  late String? distance;
  late double? latitude;
  late double? longitude;
  LocalBluetoothDevice({required super.remoteId});

  @override
  get localName {
    return super.platformName;
  }

  set localName(String name) {
    localName = name;
  }

  formJson(Map json) {
    address = json['address'];
    distance = json['distance'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['distance'] = distance;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class BluetoothDeviceModel extends ChangeNotifier {
  String name = '初始化';

  void changeName(String val) {
    debugPrint('BluetoothDeviceModel changeName: $val');
    name = val;
    notifyListeners();
  }

  // 蓝牙设备列表
  final List<LocalBluetoothDevice> _list = [];

  // 新增设备
  void add(LocalBluetoothDevice device) {
    _list.add(device);
    notifyListeners();
  }

  // 删除设备
  void remove(LocalBluetoothDevice device) {
    _list.removeWhere((e) => e.remoteId == device.remoteId);
    notifyListeners();
  }

  List<LocalBluetoothDevice> get list => _list;

  // 更新设备信息
  void update(LocalBluetoothDevice device) {
    final _device = _list.firstWhere((e) => e.remoteId == device.remoteId);
    _device.localName = device.localName ?? device.platformName;
    notifyListeners();
  }
}
