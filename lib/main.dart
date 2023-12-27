import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:da_yan_app/utils/fl_amap_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'pages/index.dart';
import 'pages/bluetooth/bluetooth_model.dart';
import 'models/location_model.dart';
import './utils/local_storage.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// 设置系统状态栏背景色
  SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
