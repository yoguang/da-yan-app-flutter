import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/device_finder_distance_indicator.dart';

class DeviceFinderView extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceFinderView({super.key, required this.device});

  @override
  State<DeviceFinderView> createState() => _DeviceFinderViewState();
}

class _DeviceFinderViewState extends State<DeviceFinderView> {
  final defaultBGColor = const Color(0xff000000); // 默认颜色
  final defaultBorderColor = const Color(0xff777777); // 默认边框颜色
  final Color _activeBGColor = const Color(0xff3A83F6); // 激活状态颜色

  int _distancesStatus = 0; // 距离：0：远，1：近，2：此处
  List<String> distancesTexts = ['距离远', '距离近', '此处'];
  List<String> distancesTips = [
    '已连接，信号弱，继续走动...',
    '信号减弱，继续走动...',
    '在附近寻找你的物品...'
  ];

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  final BluetoothDevice _device =
      BluetoothDevice(remoteId: const DeviceIdentifier('5B:0D:EF:F2:2D:84'));

  late Timer _getDeviceRssiTimer =
      Timer(const Duration(milliseconds: 1), () {});
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    initDevice();
  }

  initDevice() async {
    // 判断蓝牙适配器状态
    _adapterStateStateSubscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      debugPrint('adapterState===========>$state');
      if (state == BluetoothAdapterState.on) {
        // 连接蓝牙设备
        _device.connect().catchError((e) {
          debugPrint('device.connect Error: $e');
        });
      }
      setState(() {
        _adapterState = state;
      });
    });
    // 监听蓝牙连接状态
    _connectionStateSubscription =
        _device.connectionState.listen((state) async {
      debugPrint('BluetoothConnectionState: $state');
      if (state == BluetoothConnectionState.connected) {
        setState(() {
          _isConnected = true;
        });
        _getDeviceRssiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          getDeviceRssi();
        });
      } else {
        setState(() {
          _distancesStatus = 0;
          _isConnected = false;
        });
      }
    });
  }

  getDeviceRssi() async {
    try {
      final rssi = await _device.readRssi();
      int status;
      if (rssi > -60) {
        status = 2;
      } else if (rssi > -70) {
        status = 1;
      } else {
        status = 0;
      }
      setState(() {
        _distancesStatus = status;
      });
    } catch (e) {
      _getDeviceRssiTimer.cancel;
      debugPrint('readRssi Error: $e');
    }
  }

  // 返回
  goBack() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _getDeviceRssiTimer.cancel();
    _connectionStateSubscription.cancel();
    _adapterStateStateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final String distancesText = distancesTexts[_distancesStatus];
    final String distancesTip = distancesTips[_distancesStatus];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidthHalf = screenWidth / 2;
    final double screenHeightHalf = screenHeight / 2;

    return Scaffold(
      body: Stack(
        children: [
          // 外圈
          Positioned(
            child: AnimatedContainer(
              width: double.infinity,
              height: double.infinity,
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: _distancesStatus == 2 ? _activeBGColor : defaultBGColor,
              ),
              child: _isConnected
                  ? ClipRect(
                      child: OverflowBox(
                        maxWidth: screenHeight,
                        maxHeight: screenHeight,
                        child: Container(
                          width: screenHeight,
                          height: screenHeight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _distancesStatus == 2
                                    ? _activeBGColor
                                    : defaultBorderColor,
                                width: 6),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          // 内圈
          if (_isConnected)
            Positioned(
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: screenHeightHalf,
                  maxHeight: screenHeightHalf,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: screenWidth + 40,
                    height: screenWidth + 40,
                    decoration: BoxDecoration(
                      color: (_distancesStatus == 1 || _distancesStatus == 2)
                          ? _activeBGColor
                          : defaultBGColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              (_distancesStatus == 1 || _distancesStatus == 2)
                                  ? _activeBGColor
                                  : defaultBorderColor,
                          width: 6),
                    ),
                  ),
                ),
              ),
            ),
          // 中心点
          if (_isConnected)
            Positioned(
              child: DistanceIndicator(
                distanceStatus: _distancesStatus,
              ),
            ),
          // 顶部文字提示
          const Positioned(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 70, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '正在查找',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '你的AirPods',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 中间文字提示
          if (!_isConnected)
            const Positioned(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '正在搜索信号...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff919191),
                      ),
                    ),
                    Text(
                      '连接可能需要1分钟时间',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_adapterState == BluetoothAdapterState.off)
            Positioned(
              child: Center(
                child: Container(
                  width: screenWidth,
                  height: 100,
                  decoration: BoxDecoration(color: defaultBGColor),
                  child: const Text(
                    '请检查蓝牙开关',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          // 底部文字提示
          if (_isConnected)
            Positioned(
              bottom: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distancesText,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      distancesTip,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 底部控制按钮
          Positioned(
            width: screenWidth,
            bottom: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: ElevatedButton(
                    onPressed: goBack,
                    child: const Icon(CupertinoIcons.clear),
                  ),
                ),
                if (_isConnected)
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: ElevatedButton(
                      onPressed: () {
                        _startSpeaker(widget.device);
                      },
                      child: const Icon(CupertinoIcons.speaker_2_fill),
                    ),
                  ),
                if (_adapterState == BluetoothAdapterState.off)
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: ElevatedButton(
                      onPressed: () {
                        openAppSettings();
                      },
                      child: const Icon(Icons.bluetooth_disabled),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 播放声音
_startSpeaker(BluetoothDevice device) async {
  BluetoothCharacteristic characteristic = await _getDeviceWriteService(device);
  _wireDeviceValue(characteristic, [0x01]);
  // 3秒后停止播放
  Timer(const Duration(seconds: 3), () {
    _wireDeviceValue(characteristic, [0x00]);
  });
}

// 获取蓝牙写入服务
_getDeviceWriteService(BluetoothDevice device) async {
  try {
    final services = await device.discoverServices();
    late BluetoothCharacteristic _characteristic;
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          _characteristic = characteristic;
          break;
        }
      }
    }
    return _characteristic;
  } catch (e) {
    if (device.isConnected == false) {
      // 断开重连
      await device.connect();
      return _getDeviceWriteService(device);
    }
    debugPrint('getDeviceWriteService Error: $e');
  }
}

// 蓝牙写入
_wireDeviceValue(
    BluetoothCharacteristic characteristic, List<int> value) async {
  try {
    await characteristic.write(
      value,
      withoutResponse: characteristic.properties.writeWithoutResponse,
    );
  } catch (e) {
    debugPrint('wireDeviceValue error: $e');
  }
}
