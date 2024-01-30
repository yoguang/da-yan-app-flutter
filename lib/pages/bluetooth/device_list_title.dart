import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_model.dart';
import '/http/api.dart';
import '/models/location_model.dart';
import '/utils/location_util.dart';

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
        if (widget.device.isLose) {
          showModalPopup(context, widget.device);
        }
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
      leading: CircleAvatar(
        child: widget.device.isLose
            ? const Icon(
                CupertinoIcons.lock_circle_fill,
                size: 28,
                color: Color(0xFFF74738),
              )
            : const Icon(Icons.bluetooth),
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
        final distance = LocationUtil.formattedDistance(
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

  /// CrowdNet 更新通知提醒
  void showAlertDialog(BuildContext context, LocalBluetoothDevice device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: "知道了",
          onPressed: () {
            // Code to execute.
          },
        ),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("${device.localName} 位置已于 ${device.locationTime} 更新"),
        ),
        duration: const Duration(milliseconds: 1000 * 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  /// 已找到弹窗
  void showModalPopup(BuildContext context, LocalBluetoothDevice device) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("${device.localName} 已找到"),
        content: const Text("已找到该设备，在附近走动找找看"),
        actions: <CupertinoDialogAction>[
          // CupertinoDialogAction(
          //   isDefaultAction: true,
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   child: const Text(
          //     '取消',
          //     style: TextStyle(color: Colors.grey),
          //   ),
          // ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "确认",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  /// 请求 CrowdNet 更新
  void requestCrowdNetUpdate(LocalBluetoothDevice device) {
    if (!device.isLose) return;
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
        } else {
          connect();
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
