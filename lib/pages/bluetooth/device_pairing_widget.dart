import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '/models/location_model.dart';
import 'bluetooth_model.dart';
export 'bluetooth_model.dart';
import 'device_name_picker.dart';

import '../../http/api.dart';

class DevicePairing extends StatefulWidget {
  const DevicePairing({super.key});

  @override
  State<DevicePairing> createState() => _DevicePairingState();
}

class _DevicePairingState extends State<DevicePairing> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  late BluetoothDevice _firstDevice;
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  bool isPairing = false;

  @override
  void initState() {
    super.initState();

    // 初始化蓝牙
    initBluetooth();
  }

  // 初始化蓝牙适配器
  Future initBluetooth() async {
    try {
      // 检查设备是否支持蓝牙
      final isSupported = await FlutterBluePlus.isSupported;
      debugPrint('FlutterBluePlus.isSupported: $isSupported');
      // 监听蓝牙适配器状态
      _adapterStateStateSubscription =
          FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        setState(() {
          _adapterState = state;
        });
      });

      // 监听搜索扫描结果
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        List<ScanResult> filterResults = results
            .where((ScanResult scanResult) =>
                scanResult.rssi > -60 &&
                !scanResult.device.isConnected &&
                scanResult.device.platformName.isNotEmpty)
            .toList();
        if (filterResults.length > 0) {
          FlutterBluePlus.stopScan();
        }
        debugPrint('_filterResults------------------: $filterResults');
        if (filterResults.isEmpty) return;
        setState(() {
          _firstDevice = filterResults[0].device;
          _scanResults = filterResults;
        });
      }, onError: (e) {
        debugPrint(e.toString());
      });
    } catch (e) {
      debugPrint('Start Scan Error: $e');
    }
  }

  // 开始搜索
  Future onScanPressed() async {
    try {
      // android 在请求所有广告时速度很慢，
      // 所以我们只要求其中的 1/8
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 60),
          continuousUpdates: true,
          continuousDivisor: divisor);
    } catch (e) {
      debugPrint('Start Scan Error: $e');
    }
  }

// 停止搜索
  Future onStopPressed() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('Stop Scan Error: $e');
    }
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
    super.dispose();
  }

  void handleOk(String name) async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    final deviceModel =
        Provider.of<BluetoothDeviceModel>(context, listen: false);
    final createDevice = {
      'deviceId': _firstDevice.remoteId.toString(),
      'name': name,
      'latitude': locationModel.latitude,
      'longitude': locationModel.longitude,
      'formattedAddress': locationModel.formattedAddress,
      'address': {
        ...locationModel.toMap(),
      }
    };
    final result = await Api.connect(createDevice) as Map;
    if (!result['success']) return;
    // 新增设备触发更新
    debugPrint('createDevice----------$createDevice');
    final device = LocalBluetoothDevice(remoteId: _firstDevice.remoteId);
    createDevice['localName'] = createDevice['name'];
    device.formMap(createDevice);
    deviceModel.add(device);
    // 隐藏弹窗
    Navigator.pop(context);
    debugPrint('connect--------result----------');
  }

  @override
  Widget build(BuildContext context) {
    late Widget renderWidget = buildStartPair(context);
    // 搜索中
    if (isPairing) {
      renderWidget = buildPairing(context);
    }
    if (isPairing && _scanResults.isNotEmpty) {
      renderWidget = DeviceNamePicker(onOk: handleOk);
    }
    return renderWidget;
  }

// 准备
  Widget buildStartPair(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '添加新设备',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 45),
            child: Image.asset(
              'assets/device_not_found.png',
              width: 458 / 2,
              height: 280 / 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 18),
            child: SizedBox(
              width: 598 / 2,
              height: 96 / 2,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    isPairing = true;
                  });
                  onScanPressed();
                  debugPrint('FilledButton--------');
                },
                child: const Text(
                  '添加设备',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              '没有Tag去购买',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 搜索中
  Widget buildPairing(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '正在搜索Tag...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text('将Tag靠近此手机以开始'),
          Padding(
            padding: const EdgeInsets.only(top: 45),
            child: Image.asset(
              'assets/device_finding.gif',
              width: 230,
              height: 230,
            ),
          ),
        ],
      ),
    );
  }
}
