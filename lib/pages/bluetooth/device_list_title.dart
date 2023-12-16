import 'dart:async';

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
  const DeviceListTitle({super.key, required this.device});
  final LocalBluetoothDevice device;

  @override
  State<DeviceListTitle> createState() => _DeviceListTitleState();
}

class _DeviceListTitleState extends State<DeviceListTitle> {
  late BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

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
    await widget.device.connect();
  }

  Future updateLocation() async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    final bleModel = Provider.of<BluetoothDeviceModel>(context, listen: false);
    final device = widget.device;
    device.latitude = locationModel.latitude ?? device.latitude;
    device.longitude = locationModel.longitude ?? device.longitude;
    device.address = locationModel.toMap();
    bleModel.update(device);
  }

  void handleOnTap() {
    setState(() {});
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latLng = Provider.of<LocationModel>(context).latLng;
    final Map latLng2 = {
      'latitude': widget.device.latitude,
      'longitude': widget.device.longitude
    };
    final distance = formattedDistance(
      latLng?.toMap(),
      latLng2,
    );

    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.bluetooth),
      ),
      title: Text(widget.device.localName),
      subtitle: Text(widget.device.formattedAddress),
      trailing: distance['text'] == ''
          ? const CupertinoActivityIndicator()
          : Text(distance['text']),
      onTap: handleOnTap,
    );
  }
}
