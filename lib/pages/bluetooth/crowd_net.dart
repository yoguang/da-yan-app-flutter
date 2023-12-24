import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../http/api.dart';
import '../../utils/local_storage.dart';

class CrowdNet extends WidgetsBindingObserver {
  static final LocalStorage _localStorage = LocalStorage();

  /// 任务定时器，需要后台持续运行，大概率不会关闭
  static late Timer _connectTimer;

  /// 尝试连接间隔 秒
  static Duration duration = const Duration(seconds: 10);

  /// 连接状态监听缓存池 StreamSubscription
  static final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionStateSubscriptionMap = {};

  /// 丢失的蓝牙设备列表
  static List<BluetoothDevice> _loseDeviceList = [];

  /// 设备连接缓存池
  static Map<String, BluetoothDevice> _connectingMap = {};

  /// 开始工作
  CrowdNet.startCrowNetwork() {
    getLoseDeviceList();
    _connectTimer = Timer.periodic(duration, (timer) {
      for (BluetoothDevice device in _loseDeviceList) {
        connect(device);
      }
    });
  }

  /// 获取数据库中标记丢失的设备
  static Future<List<BluetoothDevice>> getLoseDeviceList() async {
    final result = await Api.getLoseDevice() as Map;
    if (result['success']) {
      _loseDeviceList = (result['data'] as List).map((item) {
        final device =
            BluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        return device;
      }).toList();
    }
    return _loseDeviceList;
  }

  /// 连接操作
  static connect(BluetoothDevice device) {
    final mapKey = device.remoteId.toString();

    /// 判断当前设备是否在连接池中，【是】退出
    if (_connectingMap.containsKey(mapKey)) return;
    _connectingMap[mapKey] = device;

    /// 当前设备已连接退出
    if (device.isConnected) return;

    /// 判断当前设备是否存在监听状态的流
    if (!_connectionStateSubscriptionMap.containsKey(mapKey)) {
      _connectionStateSubscriptionMap[mapKey] =
          device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.connected) {
          // 蓝牙连接成功，取消监听
          _connectionStateSubscriptionMap[mapKey]?.cancel();
          // 上报定位
          reportLocation(mapKey);

          /// 连接成功上报定位后断开连接，清除连接中的缓存
          device.disconnect();
          _connectingMap.remove(mapKey);
        }
      });
    }
    try {
      device.connect();
    } catch (e) {
      debugPrint('${device.remoteId} connect Error: ${e.toString()}');
    } finally {}
  }

  /// 上报定位接口操作
  static reportLocation(String deviceId) {
    try {
      final location = _localStorage.get('location');
      if (location == null) return;

      /// 发起http请求，更新设备位置
      Api.updateLocation({
        "deviceId": deviceId,
        "latitude": location["latitude"],
        "longitude": location["longitude"],
        "address": location,
      });
    } catch (e) {}
  }
}
