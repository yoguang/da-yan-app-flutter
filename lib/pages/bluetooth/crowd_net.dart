import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../http/api.dart';

class CrowdNet extends WidgetsBindingObserver {
  static late Timer _timer;
  // 保存连接状态监听 StreamSubscription
  static final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionStateSubscriptionMap = {};
  // 蓝牙设备列表
  static List<BluetoothDevice> _loseList = [];

  // 开始工作
  CrowdNet.startCrowNetwork() {
    getLoseDeviceList();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // connect(BluetoothDevice(
      //     remoteId: const DeviceIdentifier('5B:0B:24:EE:B4:3E')));
      _loseList.forEach((BluetoothDevice device) async {
        if (!device.isConnected) {
          await connect(device);
        }
      });
    });
  }

  static Future<List<BluetoothDevice>> getLoseDeviceList() async {
    final result = await Api.getLoseDevice() as Map;
    if (result['success']) {
      _loseList = (result['data'] as List).map((item) {
        final device =
            BluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        return device;
      }).toList();
    }
    return _loseList;
  }

  static connect(BluetoothDevice device) async {
    final mapKey = device.remoteId.toString();
    if (device.isConnected) return;
    debugPrint('$mapKey-----------------------------${device.isConnected}');
    if (!_connectionStateSubscriptionMap.containsKey(mapKey)) {
      _connectionStateSubscriptionMap[mapKey] =
          device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.connected) {
          // 蓝牙连接成功，取消监听
          _connectionStateSubscriptionMap[mapKey]?.cancel();
          debugPrint('BluetoothConnectionState.connected--------------------');
        }
      });
    }
    try {
      await device.connect(timeout: const Duration(seconds: 2));
    } catch (e) {
      debugPrint(
          '${device.remoteId} connect Error--------------------${e.toString()}');
    } finally {
      // await device.disconnect();
    }
  }
}
