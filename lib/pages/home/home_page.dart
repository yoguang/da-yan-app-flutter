import 'package:da_yan_app/pages/bluetooth/device_info_view.dart';
import 'package:da_yan_app/pages/bluetooth/device_pairing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

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
    debugPrint('localStorage accessToken: ${localStorage.get('accessToken')}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedDevice =
        Provider.of<BluetoothDeviceModel>(context).selectedDevice;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              child: BluetoothDeviceView(),
            ),
            if (selectedDevice != null)
              Positioned(
                child: DeviceInfoView(
                  device: selectedDevice,
                  onClose: () {},
                ),
              )
          ],
        ),
      ),
    );
  }
}
