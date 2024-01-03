import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../bluetooth/bluetooth_model.dart';
import '../../models/location_model.dart';
import '../../common/amap_config.dart';

class AMapViewWidget extends StatefulWidget {
  const AMapViewWidget({super.key});

  @override
  State<AMapViewWidget> createState() => _AMapViewWidgetState();
}

class _AMapViewWidgetState extends State<AMapViewWidget>
    with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  AMapController? _mapController;
  final _locationPlugin = AMapFlutterLocation();

  /// 地图视图中心点
  late LatLng _locationPosition = const LatLng(
    latitude: 39.909187,
    longitude: 116.397451,
  );
  final Map<String, Marker> _initMarkerMap = <String, Marker>{};

  /// 我的定位
  bool _isMyPosition = false;

  /// 地图中心视图自动移动延迟时间
  Timer _cameraAutoMoveTimer = Timer(const Duration(microseconds: 1), () {});

  /// 地图视图移动中
  bool _autoMoving = false;

  /// 是否显示定位小蓝点
  bool _myLocationEnabled = false;

  /// 是否显示设备信息弹窗
  bool _showDeviceInfo = false;

  /// 定位权限
  bool _hasLocationPermission = false;

  /// 是否永久拒绝授权
  bool _isPermanentlyDenied = false;

  /// 定位初始化完成
  bool _isLocationInitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getLocationPermission();
    initializeLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bluetoothDeviceModel =
        Provider.of<BluetoothDeviceModel>(context, listen: false);
    final device = bluetoothDeviceModel.selectedDevice;
    if (device != null && _mapController != null) {
      _showDeviceInfo = true;
      setState(() {});
      updateCamera(
          _mapController!,
          LatLng(
              latitude: device.latitude as double,
              longitude: device.longitude as double),
          16);
    } else if (_showDeviceInfo) {
      updateCamera(_mapController!, _locationPosition);
    }
    debugPrint('AMap Widget didChangeDependencies-----------------------');
  }

  /// 更新全局定位
  void updateLocationModel(Map<String, dynamic> location) {
    final model = Provider.of<LocationModel>(context, listen: false);
    model.fromMap(location);

    // 创建我的定位Marker
    Marker marker = Marker(
      position: LatLng(
        latitude: location["latitude"],
        longitude: location["longitude"],
      ),
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.fromIconPath('assets/markers/location_marker.png'),
    );
    _initMarkerMap['MyLocation'] = marker;
    setState(() {});
  }

  /// 初始化我的位置以及地图中心
  void initialCameraPosition(Map location) {
    if (_isLocationInitial) return;
    _isLocationInitial = true;
    final latitude =
        LocationModel.numberStringToDouble(location['latitude']) as double;
    final longitude =
        LocationModel.numberStringToDouble(location['longitude']) as double;
    final target = LatLng(
      latitude: latitude,
      longitude: longitude,
    );
    _locationPosition = target;
    if (_mapController != null) {
      updateCamera(_mapController!, target);
    }
    setState(() {});
  }

  /// 动态获取定位权限
  Future<bool> getLocationPermission() async {
    bool has = await requestLocationPermission();
    _hasLocationPermission = has;
    _myLocationEnabled = true;
    setState(() {});
    return has;
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    debugPrint('Permission.location.status-------------->$status');
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      // 已经拒绝一次，第二次永久拒绝，不再请求授权
      if (_isPermanentlyDenied &&
          status == PermissionStatus.permanentlyDenied) {
        return false;
      }
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.denied ||
          status == PermissionStatus.permanentlyDenied) {
        _isPermanentlyDenied = true;
        setState(() {});
      }

      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// 初始化定位插件
  Future<void> initializeLocation() async {
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.setApiKey(
      AMapConfig.apiKey.androidKey.toString(),
      AMapConfig.apiKey.iosKey.toString(),
    );

    /// 监听定位变化
    _locationPlugin.onLocationChanged().listen((Map<String, Object> location) {
      if (location['errorCode'] != null) {
        _locationPlugin.stopLocation();
        return;
      }
      debugPrint('location-----------------------$location');
      initialCameraPosition(location);
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
            });
        _initMarkerMap[device.remoteId.toString()] = marker;
      }
    }

    return Stack(
      children: [
        Positioned(
          child: AMapWidget(
            apiKey: AMapConfig.apiKey,
            touchPoiEnabled: false,
            compassEnabled: true,
            gestureScaleByMapCenter: true,
            privacyStatement: const AMapPrivacyStatement(
              hasAgree: true,
              hasContains: true,
              hasShow: true,
            ),
            myLocationStyleOptions: MyLocationStyleOptions(_myLocationEnabled),
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
          top: MediaQuery.of(context).size.height / 2 - 80,
          right: 10,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              final hasGranted = await requestLocationPermission();
              if (!hasGranted) {
                if (context.mounted) {
                  _showAlertDialog(context);
                }
                return;
              }
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

  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('定位权限'),
        content: const Text(
          '前往设置打开定位权限，以获取更好的体验。',
          style: TextStyle(fontSize: 16),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '暂不开启',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);

              /// 打开应用设置
              Timer(const Duration(milliseconds: 60), () {
                openAppSettings();
              });
            },
            child: const Text(
              '去设置',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void onAppLifecycleStateResumed() async {
    _hasLocationPermission = await requestLocationPermission();
    _myLocationEnabled = true;
    if (_hasLocationPermission) {
      _locationPlugin.startLocation();
    }
    setState(() {});
  }

  void onAppLifecycleStatePaused() {
    _myLocationEnabled = false;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appLifecycleState = state;
    switch (state) {
      case AppLifecycleState.inactive:
        //  应用程序处于闲置状态并且没有收到用户的输入事件。
        //注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
        debugPrint('MapWidget----->AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        // 应用程序处于不可见状态
        debugPrint('MapWidget----->AppLifecycleState.paused');
        onAppLifecycleStatePaused();
        break;
      case AppLifecycleState.resumed:
        //  进入应用时候不会触发该状态
        //  应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume。
        debugPrint('MapWidget----->AppLifecycleState.resumed');
        onAppLifecycleStateResumed();
        break;
      case AppLifecycleState.detached:
        //当前页面即将退出
        debugPrint('MapWidget----->AppLifecycleState.detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('MapWidget----->AppLifecycleState.hidden');
        break;
    }
  }
}
