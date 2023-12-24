import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import '/pages/bluetooth/device_list.dart';
import '/pages/home/amap_widget.dart';
import 'bluetooth_model.dart';
import 'device_add_button.dart';
import '/utils/local_storage.dart';

class BluetoothDeviceView extends StatefulWidget {
  const BluetoothDeviceView({super.key});

  @override
  State<BluetoothDeviceView> createState() => _BluetoothDeviceViewState();
}

class _BluetoothDeviceViewState extends State<BluetoothDeviceView> {
  late final LocalStorage localStorage = LocalStorage();
  SheetController controller = SheetController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = Provider.of<BluetoothDeviceModel>(context, listen: false);
    if (model.selectedDevice != null) {
      controller.snapToExtent(
        0.43,
        duration: const Duration(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('List Build------------------------------');
    return SnappingBottomSheet(
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.transparent,
      elevation: 1,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 16,
      snapSpec: const SnapSpec(
        initialSnap: 0.43,
        snap: true,
        positioning: SnapPositioning.relativeToAvailableSpace,
        snappings: [
          SnapSpec.headerFooterSnap,
          0.43,
          0.99,
        ],
      ),
      liftOnScrollHeaderElevation: 12.0,
      liftOnScrollFooterElevation: 12.0,
      body: const Stack(
        children: [
          AMapViewWidget(),
        ],
      ),
      headerBuilder: buildHeader,
      customBuilder: buildInfiniteChild,
    );
  }

// BottomSheet 头部
  Widget buildHeader(BuildContext context, SheetState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 8)),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 28,
              height: 4,
              color: Colors.grey[400],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '设备',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DeviceAddButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfiniteChild(
    BuildContext context,
    ScrollController controller,
    SheetState state,
  ) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
      child: SingleChildScrollView(
        controller: controller,
        child: const DeviceListWidget(),
      ),
    );
  }
}
