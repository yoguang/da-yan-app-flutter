import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../http/api.dart';
import '../../utils/date_time_util.dart';

class LocalBluetoothDevice extends BluetoothDevice {
  late Map? address;
  late double? latitude;
  late double? longitude;
  LocalBluetoothDevice({required super.remoteId});
  late bool isLose = false;

  @override
  late String localName = '';

  // 格式化地址
  String get formattedAddress {
    if (address?['formattedAddress'] == null && address?['country'] == null) {
      return '';
    }
    return address?['formattedAddress'] ??
        address?['country'] +
            address?['province'] +
            address?['city'] +
            address?['district'] +
            address?['street'] +
            address?['poiName'];
  }

  // 地址简化
  String get description => address?['description'];

  // 定位获取时间
  String get locationTime => address?['locationTime'];

  // 更新时间
  String get updateTime {
    final nowTime = DateTime.now().toString();
    return DateTimeUtil.dateTimerDifferenceToString(locationTime, nowTime);
  }

  formMap(Map map) {
    localName = map['name'];
    address = map['address'];
    latitude = map['latitude'] is double
        ? map['latitude']
        : double.parse(map['latitude']);
    longitude = map['longitude'] is double
        ? map['longitude']
        : double.parse(map['longitude']);
    isLose = map['isLose'] is bool ? map['isLose'] : false;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['localName'] = localName;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['isLose'] = isLose;
    return data;
  }

  @override
  @override
  String toString() {
    return 'LocalBluetoothDevice{'
        'remoteId: $id, '
        'localName: $localName, '
        'address: $address, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'isLose: $isLose'
        '}';
  }
}

class BluetoothDeviceModel extends ChangeNotifier {
  // 选中的设备，查看详情
  LocalBluetoothDevice? selectedDevice;

  // 设备 Sheet 窗体打开的高度
  double sheetSnapped = 0.43;

  // 改变列表视图位置
  void changeSnapped(double snap) {
    sheetSnapped = snap;
    notifyListeners();
  }

  // 蓝牙设备列表
  List<LocalBluetoothDevice> _list = [];

  // 列表选择设备
  void select(LocalBluetoothDevice? device) {
    selectedDevice = device;
    notifyListeners();
  }

  // 新增设备
  void add(LocalBluetoothDevice device) {
    _list.add(device);
    notifyListeners();
  }

  // 批量新增设备
  void addAll(List<LocalBluetoothDevice> devices) {
    clear();
    _list.addAll(devices);
    notifyListeners();
  }

  // 删除设备
  void remove(LocalBluetoothDevice device) {
    _list.removeWhere((e) => e.remoteId == device.remoteId);
    notifyListeners();
  }

  // 清空列表
  void clear() {
    _list.clear();
    notifyListeners();
  }

  List<LocalBluetoothDevice> get list => _list;

  // 更新设备信息
  void update(LocalBluetoothDevice device) {
    _list.addOrUpdate(device);
    notifyListeners();
  }

  // 获取设备列表
  Future getDevice() async {
    final result = await Api.getBoundDevice() as Map;
    if (result['success']) {
      final devices = (result['data'] as List).map((item) {
        final device =
            LocalBluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        device.formMap(item);
        return device;
      }).toList();
      addAll(devices);
    }
  }
}
