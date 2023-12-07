import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../pages/device_finder_view.dart';

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
  final List<BluetoothDevice> _devices = [
    BluetoothDevice(remoteId: const DeviceIdentifier('5B:0D:EF:F2:2D:84')),
  ];

  @override
  void initState() {
    super.initState();
  }

  void handleOnTap(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceFinderView(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DeviceInfoView();
    return Column(
      children: [
        ..._devices.map(
          (BluetoothDevice device) => ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.bluetooth),
            ),
            title: Text(device.platformName),
            subtitle: Text(device.mtuNow.toString()),
            trailing: Text(device.isConnected.toString()),
            onTap: () => {handleOnTap(device)},
          ),
        ),
      ],
    );
  }
}

class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({super.key});

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Column(
        children: [
          // 设备基本信息
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的iPhone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '中国浙江省杭州市西湖区莲花街',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  '1分钟前',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('播放'),
              Text('查找'),
            ],
          ),
        ],
      ),
    );
  }
}
