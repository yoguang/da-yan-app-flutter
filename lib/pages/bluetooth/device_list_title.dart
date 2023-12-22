import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_model.dart';
import '../../models/location_model.dart';
import '../../utils/location_util.dart' show formattedDistance;

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

class DeviceListTitle extends StatefulWidget {
  const DeviceListTitle({super.key, required this.device, this.onTap});
  final LocalBluetoothDevice device;
  final ArgumentCallback<LocalBluetoothDevice>? onTap;

  @override
  State<DeviceListTitle> createState() => _DeviceListTitleState();
}

class _DeviceListTitleState extends State<DeviceListTitle> {
  late BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        updateLocation();
      }
      setState(() {
        _connectionState = state;
      });
    });
    connect();
  }

  Future connect() async {
    try {
      await widget.device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: true,
      );
    } finally {
      _connecting = false;
      setState(() {});
    }
  }

  Future updateLocation() async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    final bleModel = Provider.of<BluetoothDeviceModel>(context, listen: false);
    final device = widget.device;
    if (locationModel.latitude == null) return;
    device.latitude = locationModel.latitude ?? device.latitude;
    device.longitude = locationModel.longitude ?? device.longitude;
    device.address = locationModel.toMap();
    bleModel.update(device);
  }

  void handleOnTap() {
    if (widget.onTap != null) {
      widget.onTap!(widget.device);
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationModel = Provider.of<LocationModel>(context);
    final Map latLng1 = {
      'latitude': locationModel.latitude,
      'longitude': locationModel.longitude,
    };

    final Map latLng2 = {
      'latitude': widget.device.latitude,
      'longitude': widget.device.longitude
    };
    final distance = formattedDistance(
      latLng1,
      latLng2,
    );

    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.bluetooth),
      ),
      title: Text(widget.device.localName),
      subtitle: Text(widget.device.formattedAddress),
      trailing: (distance['text'] == '' && _connecting)
          ? const CupertinoActivityIndicator()
          : Text(distance['text']),
      onTap: handleOnTap,
    );
  }
}
