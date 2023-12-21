import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import '/pages/bluetooth/bluetooth_model.dart';

import 'device_finder_view.dart';

class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({super.key});

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  SheetController controller = SheetController();
  bool _isPlay = false;

  @override
  Widget build(BuildContext context) {
    final deviceModel = Provider.of<BluetoothDeviceModel>(context);
    final device = deviceModel.selectedDevice;
    debugPrint('Sheet Info----------------------------');
    if (device == null) {
      return const SizedBox();
    }
    return SnappingBottomSheet(
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.transparent,
      elevation: 2,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 16,
      closeOnBackdropTap: true,
      snapSpec: SnapSpec(
        initialSnap: 0.43,
        snap: true,
        positioning: SnapPositioning.relativeToAvailableSpace,
        snappings: const [
          0.43,
          0.99,
        ],
        onSnap: (state, snap) {
          deviceModel.changeSnapped(snap!);
          debugPrint('Snapped to $snap');
        },
      ),
      liftOnScrollHeaderElevation: 12.0,
      liftOnScrollFooterElevation: 12.0,
      headerBuilder: (
        BuildContext context,
        SheetState state,
      ) {
        // 设备基本信息
        return Container(
          padding:
              const EdgeInsets.only(left: 15, top: 8, right: 15, bottom: 0),
          height: 90,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 28,
                  height: 4,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      device!.localName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton.filledTonal(
                      color: Colors.white,
                      onPressed: () {
                        final bleModel = Provider.of<BluetoothDeviceModel>(
                            context,
                            listen: false);
                        bleModel.select(null);
                      },
                      icon: const Icon(
                        Icons.close_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
              Text(
                device.formattedAddress,
                style: const TextStyle(fontSize: 14),
              ),
              const Text(
                '1分钟前',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
      customBuilder: (
        BuildContext context,
        ScrollController controller,
        SheetState state,
      ) {
        return SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 15)),
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: startPlay,
                      child: Card(
                        color: _isPlay
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        surfaceTintColor: _isPlay
                            ? Theme.of(context).primaryColor
                            : Colors.white,
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
                                const Padding(
                                    padding: EdgeInsets.only(top: 18)),
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
                                DeviceFinderView(device: device!),
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
                                const Padding(
                                    padding: EdgeInsets.only(top: 18)),
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
          ),
        );
      },
    );
  }

  // 播放声音
  startPlay() async {
    try {
      setState(() {
        _isPlay = true;
      });
      final device = Provider.of<BluetoothDeviceModel>(context, listen: false)
          .selectedDevice!;
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
