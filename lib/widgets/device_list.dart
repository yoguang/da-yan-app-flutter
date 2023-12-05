import 'package:flutter/material.dart';

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
  const DeviceListWidget({super.key, required this.devicesData});
  final List<Device> devicesData;
  // void onTap = (Device device) => {};

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  void _handleOnTap(Device device) {
    print(device.toJson());
    // this.onTap(device);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FullScreenPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    print('devicesData: ');
    print(widget.devicesData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.devicesData.map((Device device) => ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.backpack),
              ),
              title: Text(device.name),
              subtitle: Text(device.address),
              trailing: Text(device.distance),
              onTap: () => {_handleOnTap(device)},
            )),
        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.backpack),
          ),
          title: Text('Map'),
          subtitle: Text('subTitle'),
          trailing: Text('10米'),
        ),
        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.pedal_bike),
          ),
          title: Text('Album'),
          subtitle: Text('subTitle'),
        ),
        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.account_balance_wallet),
          ),
          title: Text('Phone'),
          subtitle: Text('subTitle'),
        ),
      ],
    );
  }
}

class FullScreenPage extends StatelessWidget {
  const FullScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('全屏页面')),
          body: const Center(
            child: Text('这是一个全屏的新页面，覆盖在 bottomNavigationBar 之上'),
          ),
        ),
      ],
    );
  }
}
