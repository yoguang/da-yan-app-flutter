import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:da_yan_app/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/fl_amap_location.dart';
import '../bluetooth/bluetooth_model.dart';
import '../../models/location_model.dart';

class AMapViewWidget extends StatefulWidget {
  const AMapViewWidget({super.key});

  @override
  State<AMapViewWidget> createState() => _AMapViewWidgetState();
}

class _AMapViewWidgetState extends State<AMapViewWidget>
    with WidgetsBindingObserver {
  AMapController? _mapController;
  final _locationPlugin = AMapFlutterLocation();
  late BluetoothDeviceModel? _bluetoothDeviceModel;

  static LocalStorage localStorage = LocalStorage();

  late LatLng _locationPosition = const LatLng(
    latitude: 39.909187,
    longitude: 116.397451,
  );
  final Map<String, Marker> _initMarkerMap = <String, Marker>{};
  bool _isMyPosition = false;

  /// 地图中心视图自动移动延迟定时器
  Timer _cameraAutoMoveTimer = Timer(const Duration(microseconds: 1), () {});
  bool _autoMoving = false;

  /// 是否显示设备详情
  bool _showDeviceInfo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bluetoothDeviceModel =
        Provider.of<BluetoothDeviceModel>(context, listen: false);
    requestPermission();
    initializeLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final device = _bluetoothDeviceModel?.selectedDevice;
    if (device != null && _mapController != null) {
      _showDeviceInfo = true;
      updateCamera(
          _mapController!,
          LatLng(
              latitude: device.latitude as double,
              longitude: device.longitude as double),
          16);
    } else if (_showDeviceInfo) {
      updateCamera(_mapController!, _locationPosition);
    }
    debugPrint('didChangeDependencies-----------------------$device');
  }

  /// 更新全局定位
  void updateLocationModel(Map<String, dynamic> location) {
    final model = Provider.of<LocationModel>(context, listen: false);
    model.fromMap(location);
  }

  /// 初始化地图定位点
  void initialPosition(Map location) {
    debugPrint('location===========================$location');
    final latitude = location['latitude'] as double;
    final longitude = location['longitude'] as double;
    final target = LatLng(
      latitude: latitude,
      longitude: longitude,
    );
    _locationPosition = target;
    setState(() {});
  }

  /// 动态获取定位权限
  void requestPermission() {
    FlAMapLocation().requestPermission().then((bool granted) {
      if (granted) {
        _locationPlugin.startLocation();
      } else {}
    });
  }

  /// 初始化定位插件
  Future<void> initializeLocation() async {
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.setApiKey(
      FlAMapLocation.apiKey.androidKey.toString(),
      FlAMapLocation.apiKey.iosKey.toString(),
    );

    /// 监听定位变化
    _locationPlugin.onLocationChanged().listen((Map<String, Object> location) {
      initialPosition(location);
      updateLocationModel(location);
    });

    /// 设置10秒定位间隙
    _locationPlugin
        .setLocationOption(AMapLocationOption(locationInterval: 10 * 1000));

    /// 开始定位
    _locationPlugin.startLocation();
  }

  /// 更新地图中心
  updateCamera(AMapController controller, LatLng latLng, [double zoom = 14]) {
    // 视图向上偏移量
    final offsetY = zoom > 14 ? 0.005 : 0.015;
    final position = LatLng(
        latitude: latLng.latitude - offsetY, longitude: latLng.longitude);
    final cameraUpdate = CameraUpdate.newLatLngZoom(position, zoom);
    controller.moveCamera(cameraUpdate);
  }

  /// 点击地图 Marker 选中当前Marker代表的设备
  onMarkerTab(LocalBluetoothDevice device) {
    final position = LatLng(
        latitude: device.latitude as double,
        longitude: device.longitude as double);
    Provider.of<BluetoothDeviceModel>(context, listen: false).select(device);
    updateCamera(_mapController!, position, 16);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
              onMarkerTab(device);
              debugPrint('device=================$device');
            });
        _initMarkerMap[marker.id] = marker;
      }
    }
    return Stack(
      children: [
        Positioned(
          child: AMapWidget(
            apiKey: FlAMapLocation.apiKey,
            touchPoiEnabled: false,
            privacyStatement: const AMapPrivacyStatement(
                hasAgree: true, hasContains: true, hasShow: true),
            myLocationStyleOptions: MyLocationStyleOptions(true),
            markers: Set<Marker>.of(_initMarkerMap.values),
            onMapCreated: (AMapController controller) {
              updateCamera(controller, _locationPosition);
              _mapController = controller;
              setState(() {});
            },
            onCameraMove: (CameraPosition position) {
              if (!_autoMoving) {
                _isMyPosition = false;
                setState(() {});
              }
            },
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              _isMyPosition = true;
              _autoMoving = true;
              updateCamera(_mapController!, _locationPosition);
              _cameraAutoMoveTimer =
                  Timer(const Duration(milliseconds: 500), () {
                _autoMoving = false;
                _cameraAutoMoveTimer.cancel();
                setState(() {});
              });
              setState(() {});
            },
            child: Icon(
              _isMyPosition ? Icons.adjust : Icons.my_location,
              color: _isMyPosition ? Colors.blue : Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        //  应用程序处于闲置状态并且没有收到用户的输入事件。
        //注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
        print('YM----->AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
//      应用程序处于不可见状态
        print('YM----->AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        //    进入应用时候不会触发该状态
        //  应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume。
        print('YM----->AppLifecycleState.resumed');
        break;
      case AppLifecycleState.detached:
        //当前页面即将退出
        print('YM----->AppLifecycleState.detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
