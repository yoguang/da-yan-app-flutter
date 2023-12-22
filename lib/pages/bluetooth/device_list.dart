import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth_model.dart';
import 'device_list_title.dart';
import '../../http/api.dart';

class Device {
  late String deviceId;
  late String name;
  late String address;
  late String distance;
  late double latitude;
  late double longitude;

  Device(
    this.deviceId,
    this.name,
    this.address,
    this.distance,
    this.latitude,
    this.longitude,
  );

  Device.fromJson(Map json) {
    deviceId = json["deviceId"];
    name = json["name"];
    address = json["address"];
    distance = json["distance"];
    latitude = json["latitude"];
    longitude = json["longitude"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['name'] = name;
    data['address'] = address;
    data['distance'] = distance;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class DeviceListWidget extends StatefulWidget {
  const DeviceListWidget({super.key});

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget>
    with WidgetsBindingObserver {
  late final BluetoothDeviceModel _bluetoothDeviceModel =
      Provider.of(context, listen: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getDevice();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future getDevice() async {
    final result = await Api.getBoundDevice() as Map;
    debugPrint('getDevice=================$result');
    if (result['success']) {
      final devices = (result['data'] as List).map((item) {
        final device =
            LocalBluetoothDevice(remoteId: DeviceIdentifier(item['deviceId']));
        device.formMap(item);
        return device;
      }).toList();
      _bluetoothDeviceModel.addAll(devices);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleModel = Provider.of<BluetoothDeviceModel>(context, listen: true);

    if (bleModel.list.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 30)),
            Image.asset(
              'assets/device_not_found.png',
              width: 458 / 2,
              height: 280 / 2,
            ),
            CupertinoButton(
              onPressed: () {},
              child: const Text('去添加'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        ...bleModel.list.map(
          (LocalBluetoothDevice device) {
            return DeviceListTitle(
              device: device,
              onTap: (device) {
                final model =
                    Provider.of<BluetoothDeviceModel>(context, listen: false);
                model.select(device);
              },
            );
          },
        ),
      ],
    );
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   switch (state) {
  //     case AppLifecycleState.inactive:
  //       //  应用程序处于闲置状态并且没有收到用户的输入事件。
  //       //注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
  //       print('LIST----->AppLifecycleState.inactive');
  //       break;
  //     case AppLifecycleState.paused:
  //       // 应用程序处于不可见状态
  //       print('LIST----->AppLifecycleState.paused');
  //       break;
  //     case AppLifecycleState.resumed:
  //       //    进入应用时候不会触发该状态
  //       //  应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume。
  //       print('LIST----->AppLifecycleState.resumed');
  //       break;
  //     case AppLifecycleState.detached:
  //       //当前页面即将退出
  //       print('LIST----->AppLifecycleState.detached');
  //       break;
  //     case AppLifecycleState.hidden:
  //     // TODO: Handle this case.
  //   }
  // }
}
