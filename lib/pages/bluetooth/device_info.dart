import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_finder_view.dart';

class DeviceInfoView extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onDiscover;
  const DeviceInfoView(
      {super.key, required this.device, required this.onDiscover});

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  bool _isPlay = false;

  // 播放声音
  startPlay() async {
    try {
      setState(() {
        _isPlay = true;
      });
      final device = widget.device;
      debugPrint('startPlay device isConnected: ${device.isConnected}');
      if (!device.isConnected) {
        await device.connect().catchError((e) {
          debugPrint(e.toString());
        });
        startPlay();
        return;
      }
      BluetoothCharacteristic characteristic =
          await _getDeviceWriteService(device);
      _wireDeviceValue(characteristic, [0x01]);
      // 3秒后停止播放
      Timer(const Duration(seconds: 3), () {
        _wireDeviceValue(characteristic, [0x00]);
        setState(() {
          _isPlay = false;
        });
      });
    } catch (e) {
      debugPrint('startPlay Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
      child: Column(
        children: [
          // 设备基本信息
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '我的iPhone',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.onDiscover();
                        },
                        icon: Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: Colors.grey.shade400,
                        ),
                      )
                    ],
                  ),
                ),
                const Text(
                  '中国浙江省杭州市西湖区莲花街',
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  '1分钟前',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: startPlay,
                child: Card(
                  color:
                      _isPlay ? Theme.of(context).primaryColor : Colors.white,
                  surfaceTintColor:
                      _isPlay ? Theme.of(context).primaryColor : Colors.white,
                  child: SizedBox(
                    width: 165,
                    height: 114,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _isPlay
                                ? CupertinoIcons.stop_circle_fill
                                : CupertinoIcons.play_circle_fill,
                            color: _isPlay
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 18)),
                          Text(
                            '播放声音',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isPlay ? Colors.white : null,
                            ),
                          ),
                          Text(
                            _isPlay ? '播放中' : '关闭',
                            style: TextStyle(
                              color: _isPlay ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeviceFinderView(device: widget.device),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  shadowColor: null,
                  surfaceTintColor: Colors.white,
                  child: SizedBox(
                    width: 165,
                    height: 114,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.smallcircle_fill_circle_fill,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 18)),
                          const Text(
                            '查找',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('附近'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
