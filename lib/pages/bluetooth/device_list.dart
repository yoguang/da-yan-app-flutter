import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'device_info.dart';
import 'bluetooth_model.dart';
import '../../models/location_model.dart';

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
  late LocationModel _locationModel;
  final List<BluetoothDevice> _devices = [
    BluetoothDevice(remoteId: const DeviceIdentifier('5B:0D:EF:F2:2D:84')),
    // BluetoothDevice(remoteId: const DeviceIdentifier('5B:0B:24:EE:B4:3E')),
  ];

  bool _showInfo = false;
  late Widget _DeviceInfoWidget = const SizedBox();

  @override
  void initState() {
    super.initState();
    connectDevices();
  }

  Future connectDevices() async {
    _devices.forEach((d) async {
      await d.connect();
      debugPrint('connect result: ${d.isConnected}');
    });
  }

  void handleOnTap(BluetoothDevice device) {
    _locationModel = Provider.of<LocationModel>(context, listen: false);
    debugPrint('___locationModel--------------: ${_locationModel.latitude}');
    setState(() {
      _showInfo = true;
      _DeviceInfoWidget = DeviceInfoView(
        device: device,
        onDiscover: () {
          setState(() {
            _showInfo = false;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final _name = Provider.of<BluetoothDeviceModel>(context, listen: true).name;
    if (_showInfo) {
      return _DeviceInfoWidget;
    }

    return Column(
      children: [
        Consumer<BluetoothDeviceModel>(
            builder: (_, model, __) => Text(model.name)),
        ..._devices.map(
          (BluetoothDevice device) => ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.bluetooth),
            ),
            title: Text(device.platformName),
            subtitle: Text(device.remoteId.toString()),
            trailing: Text(device.isConnected.toString()),
            onTap: () => {handleOnTap(device)},
          ),
        ),
      ],
    );
  }
}
