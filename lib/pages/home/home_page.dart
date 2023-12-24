import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/pages/bluetooth/device_info_view.dart';
import '../../utils/local_storage.dart' show LocalStorage;
import '../bluetooth/bluetooth_view.dart' show BluetoothDeviceView;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late final LocalStorage localStorage = LocalStorage();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 设置顶部状态栏
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
    debugPrint('localStorage accessToken: ${localStorage.get('accessToken')}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              child: BluetoothDeviceView(),
            ),
            Positioned(
              child: DeviceInfoView(),
            )
          ],
        ),
      ),
    );
  }
}
