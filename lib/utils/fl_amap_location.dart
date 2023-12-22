import 'dart:async';
import 'dart:io';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

typedef EventHandlerAMapLocation = void Function(Map<String, Object> location);

class FlAMapLocation {
  factory FlAMapLocation() => _singleton ??= FlAMapLocation._();

  FlAMapLocation._();

  static AMapApiKey apiKey = const AMapApiKey(
    iosKey: 'f10d6b1d907e53d9e7e5e0a14a99c224',
    androidKey: '44617b96965472ca5b90e8a737e963f0',
  );

  static FlAMapLocation? _singleton;

  bool _isInitialize = false;

  Map<String, Object>? _locationResult;

  StreamSubscription<Map<String, Object>>? _locationListener;

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();

  ///  初始化定位
  ///  @param options 启动系统所需选项
  // Future<bool> initialize(AMapLocationOption option) async {
  void initialize(
      {bool onceLocation = false,
      EventHandlerAMapLocation? onLocationChanged}) {
    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用， 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// [hasContains] 隐私声明中是否包含高德隐私政策说明
    ///
    /// [hasShow] 隐私权政策是否弹窗展示告知用户
    AMapFlutterLocation.updatePrivacyShow(true, true);

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// [hasAgree] 隐私权政策是否已经取得用户同意
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 动态申请定位权限
    requestPermission();

    ///设置Android和iOS的apiKey<br>
    ///key的申请请参考高德开放平台官网说明<br>
    ///Android: https://lbs.amap.com/api/android-location-sdk/guide/create-project/get-key
    ///iOS: https://lbs.amap.com/api/ios-location-sdk/guide/create-project/get-key

    AMapFlutterLocation.setApiKey(
      "44617b96965472ca5b90e8a737e963f0",
      "f10d6b1d907e53d9e7e5e0a14a99c224",
    );

    ///iOS 获取native精度类型
    if (Platform.isIOS) {
      requestAccuracyAuthorization();
    }

    ///注册定位结果监听
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      debugPrint(
          'FlAMapLocation↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓');
      debugPrint(result.toString());
      debugPrint(
          'FlAMapLocation↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑');
      if (onLocationChanged != null) {
        onLocationChanged(result);
      }
      _locationResult = result;
    });
    _setLocationOption(onceLocation);
    _locationPlugin.startLocation();
    _isInitialize = true;
  }

  ///  直接获取定位
  ///  @param needsAddress 是否需要详细地址信息 默认false
  Future<dynamic> getOnceLocation([bool needsAddress = false]) async {
    _locationPlugin.startLocation();
    final completer = Completer();
    return completer.future;
  }

  Future<dynamic> getLocation() async {
    final completer = Completer();
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      completer.complete(result);
      _locationResult = result;
    });
    return completer.future;
  }

  /// 启动监听位置改变
  void startLocationChanged(EventHandlerAMapLocation onLocationChanged) async {
    _setLocationOption(false);
  }

  ///  停止监听位置改变
  Future<bool> stopLocation() async {
    _locationPlugin.stopLocation();
    return true;
  }

  ///设置定位参数
  void _setLocationOption([bool onceLocation = false]) {
    AMapLocationOption locationOption = AMapLocationOption(
      ///是否单次定位
      onceLocation: onceLocation,

      ///是否需要返回逆地理信息
      needAddress: true,

      ///逆地理信息的语言类型
      geoLanguage: GeoLanguage.DEFAULT,

      ///iOS 14中设置期望的定位精度权限
      desiredLocationAccuracyAuthorizationMode:
          AMapLocationAccuracyAuthorizationMode.FullAccuracy,

      ///设置Android端连续定位的定位间隔
      locationInterval: 10 * 1000,

      ///设置Android端的定位模式<br>
      locationMode: AMapLocationMode.Hight_Accuracy,

      ///设置iOS端的定位最小更新距离<br>
      distanceFilter: -1,

      ///设置iOS端期望的定位精度
      desiredAccuracy: DesiredAccuracy.Best,

      ///设置iOS端是否允许系统暂停定位
      pausesLocationUpdatesAutomatically: false,
    );
    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  ///获取iOS native的accuracyAuthorization类型
  void requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
        await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }

  /// 动态申请定位权限
  Future<bool> requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      _locationPlugin.startLocation();
      debugPrint("hasLocationPermission=================>定位权限申请通过");
      return true;
    } else {
      debugPrint("hasLocationPermission=================>定位权限申请不通过");
      return false;
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// 销毁定位参数
  Future<bool> dispose() async {
    if (!_isInitialize) return false;

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener?.cancel();
    }

    ///销毁定位
    _locationPlugin.destroy();
    return true;
  }
}
