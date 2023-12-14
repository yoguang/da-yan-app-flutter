import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import './bluetooth_model.dart';
export './bluetooth_model.dart';

class DevicePairing extends StatefulWidget {
  const DevicePairing({super.key});

  @override
  State<DevicePairing> createState() => _DevicePairingState();
}

class _DevicePairingState extends State<DevicePairing> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

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
        debugPrint('scanResults: $results');
        setState(() {
          List<ScanResult> filterResults = results
              .where((ScanResult scanResult) =>
                  scanResult.rssi > -60 &&
                  !scanResult.device.isConnected &&
                  scanResult.device.platformName.isNotEmpty)
              .toList();
          if (filterResults.length > 0) {
            FlutterBluePlus.stopScan();
          }
          debugPrint('------------------_filterResults: $filterResults');
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

  @override
  Widget build(BuildContext context) {
    late Widget renderWidget = buildStartPair(context);
    // 搜索中
    if (isPairing) {
      renderWidget = buildPairing(context);
    }
    if (isPairing && _scanResults.isNotEmpty) {
      renderWidget = const DevicePaired();
    }
    return renderWidget;
  }

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
              '正在搜搜Tag...',
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

class DevicePaired extends StatefulWidget {
  const DevicePaired({super.key});

  @override
  State<DevicePaired> createState() => _DevicePairedState();
}

class _DevicePairedState extends State<DevicePaired> {
  final double _kItemExtent = 32.0;
  final List<String> _deviceNames = <String>[
    '背包',
    '钥匙',
    '钱包',
    '伞',
    '自行车',
    '自定义命名',
  ];
  int _selectedIndex = 2;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _deviceNames[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_nameController: ${_nameController.text}');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 18),
            child: Text(
              '设置名称',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: _kItemExtent,
              // This sets the initial item.
              scrollController: FixedExtentScrollController(
                initialItem: _selectedIndex,
              ),
              // This is called when selected item is changed.
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selectedIndex = selectedItem;
                  _nameController.text = _deviceNames[selectedItem];
                });
              },
              children: List<Widget>.generate(_deviceNames.length, (int index) {
                return Center(child: Text(_deviceNames[index]));
              }),
            ),
          ),
          if (_selectedIndex == 5)
            SizedBox(
              width: 300,
              height: 48,
              child: TextField(
                controller: _nameController,
              ),
            ),
          if (_selectedIndex != 5)
            const SizedBox(
              height: 48,
            ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    final model = Provider.of<BluetoothDeviceModel>(context,
                        listen: false);
                    model.changeName(_nameController.text);
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
