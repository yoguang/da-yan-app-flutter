import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_model.dart';
import '/http/api.dart';
import '/models/location_model.dart';
import '/utils/location_util.dart' show formattedDistance;

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

class _DeviceListTitleState extends State<DeviceListTitle>
    with WidgetsBindingObserver {
  late BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  // 蓝牙连接中
  late bool _connecting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        updateLocation();
      }
      _connectionState = state;
      setState(() {});
    });
    connect();
  }

  Future connect() async {
    try {
      await widget.device.connect();
    } finally {
      _connecting = false;
      setState(() {});
    }
  }

  Future updateLocation() async {
    try {
      final locationModel = Provider.of<LocationModel>(context, listen: false);
      final bleModel =
          Provider.of<BluetoothDeviceModel>(context, listen: false);
      final device = widget.device;
      if (locationModel.city!.isEmpty || locationModel.city == '') return;
      device.latitude = locationModel.latitude ?? device.latitude;
      device.longitude = locationModel.longitude ?? device.longitude;
      device.address = locationModel.toMap();
      bleModel.update(device);

      /// 发起http请求，更新设备位置
      Api.updateLocation({
        "deviceId": device.remoteId.toString(),
        "latitude": device.latitude,
        "longitude": device.longitude,
        "address": device.address,
      });
    } catch (e) {}
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
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.bluetooth),
      ),
      title: Text(widget.device.localName),
      subtitle:
          Text("${widget.device.description}·${widget.device.updateTime}"),
      trailing: Consumer<LocationModel>(builder: (_, locationModel, __) {
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
        if (_connecting) {
          return const CupertinoActivityIndicator();
        } else {
          return Text(distance['text']);
        }
      }),
      onTap: handleOnTap,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // 应用程序处于闲置状态并且没有收到用户的输入事件。
        // 注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
        break;
      case AppLifecycleState.paused:
        // 应用程序处于不可见状态
        break;
      case AppLifecycleState.resumed:
        // 进入应用时候不会触发该状态
        // 应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume。
        if (_connectionState == BluetoothConnectionState.connected) {
          updateLocation();
        }
        break;
      case AppLifecycleState.detached:
        // 当前页面即将退出
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
