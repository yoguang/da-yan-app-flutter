import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:da_yan_app/utils/fl_amap_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'pages/index.dart';
import 'pages/bluetooth/bluetooth_model.dart';
import 'models/location_model.dart';
import './utils/local_storage.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // initializeLocation();
  await LocalStorage.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothDeviceModel()),
        ListenableProvider(create: (_) => LocationModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '大雁',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

Future<void> initializeLocation() async {
  /// 动态申请定位权限
  final hasPermission = await FlAMapLocation().requestPermission();

  if (!hasPermission) return;
  final _locationPlugin = AMapFlutterLocation();
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  AMapFlutterLocation.setApiKey(
    "44617b96965472ca5b90e8a737e963f0",
    "f10d6b1d907e53d9e7e5e0a14a99c224",
  );

  /// 监听定位变化
  _locationPlugin
      .onLocationChanged()
      .listen((Map<String, Object> location) async {
    debugPrint('main hasPermission===========================$hasPermission');
    debugPrint('main location===========================$location');
  });

  /// 设置10秒定位间隙
  _locationPlugin
      .setLocationOption(AMapLocationOption(locationInterval: 10 * 1000));

  /// 开始定位
  _locationPlugin.startLocation();
}
