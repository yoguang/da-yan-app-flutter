import 'dart:async';

import 'package:da_yan_app/http/api.dart';
import 'package:da_yan_app/models/location_model.dart';
import 'package:da_yan_app/utils/index.dart';
import 'package:da_yan_app/utils/location_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:map_launcher/map_launcher.dart';
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
  final Map mapTypeName = {
    "apple": "苹果地图",
    "amap": "高德地图",
    "baidu": "百度地图",
    "tencent": "腾讯地图"
  };

  late List<AvailableMap> availableMaps;
  SheetController controller = SheetController();
  bool _isPlay = false;
  bool _isOpen = false;

  /// 通知开关
  bool _notifySwitched = false;

  /// 丢失开关
  bool _loseSwitched = false;

  @override
  void initState() {
    super.initState();
    installedMaps();
  }

  installedMaps() async {
    availableMaps = await MapLauncher.installedMaps;
    debugPrint('availableMaps------------$availableMaps');
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deviceModel =
        Provider.of<BluetoothDeviceModel>(context, listen: false);
    if (deviceModel.selectedDevice != null) {
      _isOpen = true;
      setState(() {});
      controller.snapToExtent(0.43,
          duration: const Duration(milliseconds: 500));
    } else {
      controller.snapToExtent(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceModel = Provider.of<BluetoothDeviceModel>(context);
    debugPrint('Device Info build------------');
    return SnappingBottomSheet(
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.transparent,
      elevation: 2,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 16,
      closeOnBackdropTap: true,
      snapSpec: SnapSpec(
        initialSnap: 0.0,
        snap: true,
        snappings: const [
          0.0,
          0.43,
          0.99,
        ],
        onSnap: (state, snap) {
          if (snap == 0.0 && _isOpen) {
            _isOpen = false;
            setState(() {});
            final deviceModel =
                Provider.of<BluetoothDeviceModel>(context, listen: false);
            deviceModel.select(null);
          }
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
                    Selector<BluetoothDeviceModel, LocalBluetoothDevice?>(
                      selector: (_, provider) => provider.selectedDevice,
                      builder: (_, device, __) {
                        return Text(
                          device?.localName ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    Consumer<BluetoothDeviceModel>(
                      builder: (_, provider, __) {
                        return IconButton.filledTonal(
                          color: Colors.white,
                          onPressed: () {
                            provider.select(null);
                          },
                          icon: const Icon(
                            Icons.close_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              Consumer<BluetoothDeviceModel>(builder: (_, provider, __) {
                final device = provider.selectedDevice;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device?.formattedAddress ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      device?.updateTime ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              })
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
                                    fontSize: 18,
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
                    Consumer<LocationModel>(builder: (_, provider, child) {
                      final Map latLng1 = {
                        'latitude': provider.latitude,
                        'longitude': provider.longitude,
                      };
                      final Map latLng2 = {
                        'latitude': deviceModel.selectedDevice?.latitude,
                        'longitude': deviceModel.selectedDevice?.longitude,
                      };
                      final distance = formattedDistance(
                        latLng1,
                        latLng2,
                      );
                      return GestureDetector(
                        onTap: () {
                          if (distance["value"] > 0.01) {
                            _showMapActionSheet(context);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeviceFinderView(),
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
                                    distance["value"] > 0.01
                                        ? CupertinoIcons
                                            .arrow_up_right_diamond_fill
                                        : CupertinoIcons
                                            .smallcircle_fill_circle_fill,
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 18)),
                                  Text(
                                    distance["value"] > 0.01 ? "路线" : "查找",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(distance["text"]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                /// 通知开关
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 15),
                  surfaceTintColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 17, left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.bell_circle_fill,
                              size: 28,
                              color: Color(0xFFFF3D58),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20)),
                            Text(
                              "通知",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 15)),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: Color(0xffe4e4e4),
                      ),
                      CupertinoListTile(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 12,
                          right: 15,
                          bottom: 12,
                        ),
                        title: const Text("找到时通知"),
                        additionalInfo: CupertinoSwitch(
                          value: _notifySwitched,
                          onChanged: (bool switched) {
                            _notifySwitched = !_notifySwitched;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// 标记为丢失开关
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 15),
                  surfaceTintColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 17, left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.lock_circle_fill,
                              size: 28,
                              color: Color(0xFFF74738),
                            ),
                            Padding(padding: EdgeInsets.only(top: 15)),
                            Text(
                              "标记为丢失",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20)),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: Color(0xffe4e4e4),
                      ),
                      CupertinoListTile(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 12,
                          right: 15,
                          bottom: 12,
                        ),
                        title: Text(
                          _loseSwitched ? "已启用" : "启用",
                          style: TextStyle(
                              color: _loseSwitched ? Colors.red : Colors.blue),
                        ),
                        trailing: _loseSwitched
                            ? const CupertinoListTileChevron()
                            : null,
                        onTap: () {
                          _showAlertDialog(
                            context,
                            title: _loseSwitched ? "关闭丢失模式" : "启用丢失模式",
                            content: "修改当前丢失状态",
                            onPressed: () async {
                              await Api.updateLoseStatus({
                                "deviceId": deviceModel.selectedDevice!.remoteId
                                    .toString(),
                                "isLose": !_loseSwitched,
                              });
                              _loseSwitched = !_loseSwitched;
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                /// 抹掉此设备
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  margin: const EdgeInsets.only(top: 15),
                  child: CupertinoListTile(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 12,
                      right: 15,
                      bottom: 12,
                    ),
                    title: const Text(
                      "抹掉此设备",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      _showAlertDialog(
                        context,
                        title: "您确认要抹掉此设备吗？",
                        content: "抹掉后将不再显示在你的设备列表中，请慎重选择。",
                        onPressed: () async {
                          await Api.delete({
                            "deviceId":
                                deviceModel.selectedDevice!.remoteId.toString()
                          });
                          deviceModel.remove(deviceModel.selectedDevice!);
                          deviceModel.select(null);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// 操作确认弹窗
  void _showAlertDialog(BuildContext context,
      {String title = "提示", String content = "", onPressed}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              await onPressed();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 地图导航
  void _showMapActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) =>
          Selector<BluetoothDeviceModel, LocalBluetoothDevice>(
              selector: (_, provider) => provider.selectedDevice!,
              builder: (_, device, __) {
                return CupertinoActionSheet(
                  title: const Text('选择地图'),
                  actions: availableMaps
                      .map<CupertinoActionSheetAction>(
                          (AvailableMap map) => CupertinoActionSheetAction(
                                onPressed: () {
                                  map.showDirections(
                                    destination: Coords(
                                      device.latitude!,
                                      device.longitude!,
                                    ),
                                    destinationTitle: device.description,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  mapTypeName[Utils.enumToString(map.mapType)],
                                ),
                              ))
                      .toList(),
                  cancelButton: CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),
                );
              }),
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
