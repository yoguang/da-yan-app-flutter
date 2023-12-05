import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  static String _position = '定位中...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_position),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.play_arrow),
            onPressed: () => {_getCurrentPosition()},
          ),
          SizedBox(),
          FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: () => {},
          ),
          SizedBox(),
          FloatingActionButton(
            child: const Icon(Icons.bookmark),
            onPressed: () => {},
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    // 判断定位授权情况
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );
    print('current position: ');
    print(position);
    setState(() {
      _position = position.toString();
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    print('serviceEnabled: ');
    print(serviceEnabled);
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('LocationPermission.denied');

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('LocationPermission.deniedForever');

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('LocationPermission Result: ');
    print(permission);
    return true;
  }
}
