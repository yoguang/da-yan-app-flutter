import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:da_yan_app/utils/fl_amap_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_model.dart';
import '../../models/location_model.dart';

class AMapViewWidget extends StatefulWidget {
  AMapViewWidget({super.key, this.markers});
  List<LatLng>? markers;

  @override
  State<AMapViewWidget> createState() => _AMapViewWidgetState();
}

class _AMapViewWidgetState extends State<AMapViewWidget> {
  static const _apiKey = AMapApiKey(
    iosKey: 'f10d6b1d907e53d9e7e5e0a14a99c224',
    androidKey: '44617b96965472ca5b90e8a737e963f0',
  );

  AMapController? _mapController;
  Marker? _myLocationMarker;

  late LatLng _locationPosition = const LatLng(
    latitude: 39.909187,
    longitude: 116.397451,
  );

  final Map<String, Marker> _initMarkerMap = <String, Marker>{};

  bool _startLocation = false;

  @override
  void initState() {
    super.initState();
    FlAMapLocation().initialize(
        onceLocation: true,
        onLocationChanged: (location) {
          initialPosition(location);
          updateLocation(location);
        });
  }

  void updateLocation(Map<String, dynamic> location) {
    final model = Provider.of<LocationModel>(context, listen: false);
    model.fromMap(location);
  }

  void initialPosition(Map location) {
    final latitude = location['latitude'] as double;
    final longitude = location['longitude'] as double;
    final target = LatLng(
      latitude: latitude,
      longitude: longitude,
    );

    Marker myLocationMarker = Marker(
      anchor: const Offset(0.5, 0.5),
      position: target,
      icon: BitmapDescriptor.fromIconPath('assets/markers/location_marker.png'),
    );
    _myLocationMarker = myLocationMarker;
    _initMarkerMap[myLocationMarker.id] = myLocationMarker;
    _locationPosition = target;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final devices = Provider.of<BluetoothDeviceModel>(context).list;
    if (devices.isNotEmpty) {
      for (var device in devices) {
        Marker marker = Marker(
            position: LatLng(
                latitude: device.latitude as double,
                longitude: device.longitude as double),
            onTap: (String id) {
              debugPrint('device=================$device');
            });
        _initMarkerMap[marker.id] = marker;
      }
    }
    AMapWidget mapView = AMapWidget(
      apiKey: _apiKey,
      myLocationStyleOptions: MyLocationStyleOptions(_startLocation),
      markers: Set<Marker>.of(_initMarkerMap.values),
      onMapCreated: (AMapController controller) {
        // 视图向上偏移量
        const offsetY = 0.0150;
        final position = LatLng(
            latitude: _locationPosition.latitude - offsetY,
            longitude: _locationPosition.longitude);
        final cameraUpdate = CameraUpdate.newLatLngZoom(position, 14);
        controller.moveCamera(cameraUpdate);
        _mapController = controller;
        setState(() {});
      },
    );
    return Stack(
      children: [
        Positioned(
          child: mapView,
        ),
        Positioned(
          top: 40,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              if (_startLocation && _myLocationMarker != null) {
                _initMarkerMap[_myLocationMarker!.id] = _myLocationMarker!;
              } else {
                _initMarkerMap.remove(_myLocationMarker!.id);
              }
              _startLocation = !_startLocation;
              setState(() {});
            },
            child: Icon(
              Icons.my_location,
              color: _startLocation ? Colors.blue : Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
