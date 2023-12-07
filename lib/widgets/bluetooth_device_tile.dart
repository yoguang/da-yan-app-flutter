import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class LocalBluetoothDevice extends BluetoothDevice {
  // 地理地址
  final String? address;
  // 纬度
  final double? latitude;
  // 经度
  final double? longitude;

  LocalBluetoothDevice(
    BluetoothDevice device,
    this.address,
    this.latitude,
    this.longitude,
  ) : super(remoteId: device.remoteId);
}

class BluetoothDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const BluetoothDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    Key? key,
  }) : super(key: key);

  @override
  State<BluetoothDeviceTile> createState() => _BluetoothDeviceTileState();
}

class _BluetoothDeviceTileState extends State<BluetoothDeviceTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      _connectionState = state;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.bluetooth),
      ),
      title: Text(widget.device.platformName),
      subtitle: Text(widget.device.remoteId.toString()),
      trailing: Text('1米'),
      onTap: () {
        widget.onOpen();
        debugPrint('ListTitle onTap');
      },
    );
  }
}
