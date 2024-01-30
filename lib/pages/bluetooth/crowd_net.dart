import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../http/api.dart';
import '../../utils/local_storage.dart';

class CrowdNet {
  static final LocalStorage _localStorage = LocalStorage();

  /// 接收 BuildContext
  static BuildContext? _buildContext;

  /// 任务定时器，需要后台持续运行，大概率不会关闭
  static Timer _connectTimer = Timer(const Duration(microseconds: 1), () {});

  /// 尝试连接间隔 秒
  static Duration duration = const Duration(seconds: 10);

  /// 蓝牙搜索监听
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  /// 连接状态监听缓存池 StreamSubscription
  static final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionStateSubscriptionMap = {};

  /// 丢失的蓝牙设备列表
  static List<BluetoothDevice> _loseDeviceList = [];

  /// 设备连接缓存池
  static final Map<String, BluetoothDevice> _connectingMap = {};

  /// 缓存60秒内以上报的设备列表
  static final Map<String, BluetoothDevice> _reportCache = {};

  /// 开始工作
  CrowdNet.startCrowNetwork(BuildContext context) {
    _buildContext = context;
    initScanResultsSubscription();
    onScanPressed();
    Timer.periodic(duration, (timer) {
      /// 清空缓存列表
      _reportCache.clear();

      /// 停止上一个蓝牙扫描
      FlutterBluePlus.stopScan();

      /// 开始新的扫描
      onScanPressed();
    });
    // 仅演示使用，3秒更新一次丢失列表
    Timer.periodic(const Duration(seconds: 3), (timer) {
      getLoseDeviceList();
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
    debugPrint('CrowdNet.getLoseDeviceList--------$_loseDeviceList');
    return _loseDeviceList;
  }

  /// 初始化蓝牙扫描
  void initScanResultsSubscription() {
    // 监听搜索扫描结果
    _scanResultsSubscription =
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      debugPrint('CrowdNet.FlutterBluePlus.scanResults: $results');
      for (var element in results) {
        final loseDevice = _loseDeviceList.firstWhereOrNull(
            (device) => device.remoteId == element.device.remoteId);
        if (loseDevice != null) {
          final remoteId = loseDevice.remoteId.toString();
          debugPrint('CrowdNet.found.loseDevice-------------$loseDevice');
          // if (!_reportCache.containsKey(remoteId)) {
          reportLocation(loseDevice.remoteId.toString());
          _reportCache[remoteId] = loseDevice;
          // }
        }
      }
    }, onError: (e) {
      debugPrint("FlutterBluePlus.scanResults.listen Error: $e");
    });
  }

  /// 开始搜索蓝牙设备
  Future onScanPressed() async {
    try {
      // android 在请求所有广告时速度很慢，
      // 所以我们只要求其中的 1/8
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
        // 按广告名称过滤（完全匹配）
        // withNames: ["iTAG "],
        // 按广告名称过滤（匹配任何子字符串）
        // 水滴设备广告名称iTAG后面有个空格，用此属性过滤
        withKeywords: ["iTAG"],
        // 过滤已知的remoteIds（iOS：128位guid，android：48位mac地址
        timeout: duration,
        // 如果为“true”，我们将通过处理不断更新“lastSeen”和“rssi”
        continuousUpdates: true,
        continuousDivisor: divisor,
      );
    } catch (e) {
      debugPrint('FlutterBluePlus.startScan Error: $e');
    }
  }

  /// 上报定位接口操作
  static reportLocation(String deviceId) {
    try {
      final location = _localStorage.get('location');
      if (location == null || location['city'] == '') return;
      if (_buildContext != null) {
        // showAlertDialog(_buildContext!, deviceId);
      }
      debugPrint('CrowdNet.reportLocation---------------');

      /// 发起http请求，更新设备位置
      Api.updateLocation({
        "deviceId": deviceId,
        "latitude": location["latitude"],
        "longitude": location["longitude"],
        "address": location,
      });
    } catch (e) {}
  }

  /// 连接操作
  static connect(BluetoothDevice device) {
    final mapKey = device.remoteId.toString();

    /// 判断当前设备是否在连接池中，【是】退出
    // if (_connectingMap.containsKey(mapKey)) return;
    // _connectingMap[mapKey] = device;

    /// 当前设备已连接退出
    if (device.isConnected) return;
    if (_connectionStateSubscriptionMap.containsKey(mapKey)) {
      _connectionStateSubscriptionMap[mapKey]?.cancel();
    }
    _connectionStateSubscriptionMap[mapKey] =
        device.connectionState.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.connected) {
        /// 蓝牙连接成功，取消监听
        _connectionStateSubscriptionMap[mapKey]?.cancel();

        debugPrint('CrowdNet.Bluetooth.connect--------->$state');

        /// 上报定位
        reportLocation(mapKey);

        /// 连接成功上报定位后断开连接，清除连接中的缓存
        device.disconnect();
        _connectingMap.remove(mapKey);
      } else {
        /// 失败移出连接池
        _connectingMap.remove(mapKey);
      }
    });

    /// 判断当前设备是否存在监听状态的流
    // if (!_connectionStateSubscriptionMap.containsKey(mapKey)) {
    //   _connectionStateSubscriptionMap[mapKey] =
    //       device.connectionState.listen((BluetoothConnectionState state) {
    //     if (state == BluetoothConnectionState.connected) {
    //       /// 蓝牙连接成功，取消监听
    //       _connectionStateSubscriptionMap[mapKey]?.cancel();

    //       debugPrint('BluetoothConnectionState-$device---------$state');

    //       /// 上报定位
    //       reportLocation(mapKey);

    //       /// 连接成功上报定位后断开连接，清除连接中的缓存
    //       device.disconnect();
    //       _connectingMap.remove(mapKey);
    //     } else {
    //       /// 失败移出连接池
    //       _connectingMap.remove(mapKey);
    //     }
    //   });
    // }
    try {
      device.connect();
    } catch (e) {
      debugPrint('${device.remoteId} connect Error: ${e.toString()}');
    } finally {}
  }

  static showAlertDialog(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: '知道了',
          onPressed: () {
            // Code to execute.
          },
        ),
        content: Text("上报遗失：$msg"),
        duration: const Duration(milliseconds: 1000 * 3),
        width: 280.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  /// 应用进入后台任务
  CrowdNet.startBackgroundTasks() {
    _connectTimer = Timer.periodic(duration, (timer) {
      for (var device in _loseDeviceList) {
        connect(device);
      }
    });
  }

  /// 停止后台任务
  CrowdNet.stopBackgroundTasks() {
    _connectTimer.cancel();
  }
}
