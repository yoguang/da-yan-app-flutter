import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import 'device_info_view.dart';
import 'bluetooth_model.dart';
import 'device_list_title.dart';
import '../../http/api.dart';
import 'device_info_view.dart' show DeviceInfoView;

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
  const DeviceListWidget({super.key});

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

  void handleOnTap(LocalBluetoothDevice device) {
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
    if (bleModel.list.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 30)),
            Image.asset(
              'assets/device_not_found.png',
              width: 458 / 2,
              height: 280 / 2,
            ),
            CupertinoButton(
              onPressed: () {},
              child: const Text('去添加'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        ...bleModel.list.map(
          (LocalBluetoothDevice device) {
            return DeviceListTitle(
              device: device,
              onTap: (device) {
                final model =
                    Provider.of<BluetoothDeviceModel>(context, listen: false);
                model.select(device);
              },
            );
          },
        ),
      ],
    );
  }
}
