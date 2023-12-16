import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'device_info.dart';
import 'bluetooth_model.dart';
import 'device_list_title.dart';
import '../../http/api.dart';

class Device {
  late String deviceId;
  late String name;
  late String address;
  late String distance;
  late double latitude;
  late double longitude;

  Device(
    this.deviceId,
    this.name,
    this.address,
    this.distance,
    this.latitude,
    this.longitude,
  );

  Device.fromJson(Map json) {
    deviceId = json["deviceId"];
    name = json["name"];
    address = json["address"];
    distance = json["distance"];
    latitude = json["latitude"];
    longitude = json["longitude"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['name'] = name;
    data['address'] = address;
    data['distance'] = distance;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class DeviceListWidget extends StatefulWidget {
  const DeviceListWidget({super.key, required this.devicesData});
  final List<Device> devicesData;

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  late final BluetoothDeviceModel _bluetoothDeviceModel =
      Provider.of(context, listen: false);

  bool _showInfo = false;
  late Widget _DeviceInfoWidget = const SizedBox();

  @override
  void initState() {
    super.initState();
    getDevice();
  }

  Future getDevice() async {
    final result = await Api.getBoundDevice() as Map;
    if (result['success']) {
      final devices = (result['data'] as List).map((item) {
        final device =
            LocalBluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        device.formMap(item);
        return device;
      }).toList();
      _bluetoothDeviceModel.addAll(devices);
    }
  }

  void handleOnTap(BluetoothDevice device) {
    setState(() {
      _showInfo = true;
      _DeviceInfoWidget = DeviceInfoView(
        device: device,
        onClose: () {
          setState(() {
            _showInfo = false;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleModel = Provider.of<BluetoothDeviceModel>(context, listen: true);
    if (_showInfo) {
      return _DeviceInfoWidget;
    }

    return Column(
      children: [
        ...bleModel.list.map(
          (LocalBluetoothDevice device) {
            return DeviceListTitle(device: device);
          },
        ),
      ],
    );
  }
}
