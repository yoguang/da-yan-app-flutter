import 'package:flutter/material.dart';
import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart' show LocationModel;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  AMapController? controller;

  @override
  void initState() {
    super.initState();
    initPermission();
  }

  @override
  Widget build(BuildContext context) {
    LocationModel location = Provider.of<LocationModel>(context, listen: true);
    LatLng latLng = const LatLng(39.909187, 116.397451);
    if (location.latitude != null) {
      latLng = LatLng(location.latitude, location.longitude);
    }

    return Center(
      child: AMapView(
        options: AMapOptions(
          mapType: MapType.standard,
          showCompass: false,
          showTraffic: false,
          showScale: false,
          showIndoorMap: false,
          showUserLocation: true,
          latLng: latLng,
        ),
        onCreateController: (AMapController controller) {
          this.controller = controller;
          controller.setTrackingMode(TrackingMode.locate).then((_) {
            controller
                .setTrackingMode(TrackingMode.followLocationRotateNoCenter);
          });
          // controller.addListener();
        },
      ),
    );
  }

  /// 初始化定位权限
  Future<void> initPermission() async {
    if (!await getPermission(Permission.location)) {
      print('未获取到定位权限');
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}

Future<bool> getPermission(Permission permission) async {
  final PermissionStatus status = await permission.request();
  if (!status.isGranted) {
    // await openAppSettings();
    return await permission.request().isGranted;
  }
  return status.isGranted;
}
