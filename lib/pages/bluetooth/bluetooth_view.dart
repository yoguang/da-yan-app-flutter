import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../widgets/bluetooth_device_tile.dart';
import 'device_finder_view.dart';

class BluetoothView extends StatefulWidget {
  const BluetoothView({super.key});

  @override
  State<BluetoothView> createState() => _BluetoothViewState();
}

class _BluetoothViewState extends State<BluetoothView> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.setLogLevel(LogLevel.none);
    // 判断蓝牙适配器状态
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        _adapterState = state;
      });
    });

    //
    FlutterBluePlus.systemDevices.then((devices) {
      // debugPrint('systemDevices: $devices');
      setState(() {
        _connectedDevices = devices;
      });
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      debugPrint('scanResults: $results');
      setState(() {
        List<ScanResult> filterResults = results
            .where((ScanResult scanResult) =>
                scanResult.rssi > -60 &&
                scanResult.device.platformName.isNotEmpty)
            .toList();
        debugPrint('_filterResults: $filterResults');
        _scanResults = filterResults;
      });
    }, onError: (e) {
      debugPrint(e.toString());
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      setState(() {
        _isScanning = state;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
  }

  Future onScanPressed() async {
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      // android 在请求所有广告时速度很慢，
      // 所以我们只要求其中的 1/8
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          continuousUpdates: true,
          continuousDivisor: divisor);
    } catch (e) {
      debugPrint('Start Scan Error: $e');
    }
    setState(() {});
  }

  Future onStopPressed() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('Stop Scan Error: $e');
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    print('device------------------');
    print(device);
    device.connect().catchError((e) {
      debugPrint('device.connect Error: $e');
    });
  }

  gotoDeviceFinderView() {
    // 初始化蓝牙设备
    BluetoothDevice device =
        BluetoothDevice(remoteId: const DeviceIdentifier('5B:0D:EF:F2:2D:84'));

    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => DeviceFinderView(device: device),
      settings: const RouteSettings(name: '/DeviceFiner'),
    );
    Navigator.of(context).push(route);
  }

  // 创建页面从底部进入路由
  Route _createAnimationRoute(BluetoothDevice device) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          DeviceFinderView(device: device),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_adapterState.toString());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: gotoDeviceFinderView,
            child: Text('根据已知remoteId链接蓝牙'),
          ),
          TextButton(onPressed: onScanPressed, child: Text('扫描')),
          TextButton(onPressed: onStopPressed, child: Text('停止扫描')),
          ..._scanResults.map(
            (e) => BluetoothDeviceTile(
              device: e.device,
              onOpen: () {
                onConnectPressed(e.device);
              },
              onConnect: () {
                onConnectPressed(e.device);
              },
            ),
          )
        ],
      ),
    );
  }
}
