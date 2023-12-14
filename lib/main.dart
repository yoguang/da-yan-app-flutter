import 'package:da_yan_app/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'pages/home/home_view.dart';
import 'pages/community/community_view.dart';
import 'pages/personal/personal_view.dart';
import 'pages/bluetooth/bluetooth_view.dart';
import 'pages/bluetooth/bluetooth_model.dart';
import 'models/location_model.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 设置高德地图 APIKey
  setAMapKey(
    iosKey: 'f10d6b1d907e53d9e7e5e0a14a99c224',
    androidKey: '44617b96965472ca5b90e8a737e963f0',
    isAgree: true,
    isContains: true,
    isShow: true,
  ).then((value) {
    debugPrint('高德地图ApiKey设置$value');
  });
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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late LocationModel? _locationModel;
  int _currentPageIndex = 0;
  List<Widget> tabPages = const [
    HomeView(),
    BluetoothView(),
    CommunityPage(),
    PersonalView(),
  ];

  List<BottomNavigationBarItem> bottomNavBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.commute_rounded),
      label: '社区',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _locationModel = Provider.of<LocationModel>(context, listen: false);
    FlutterNativeSplash.remove();
    initLocation();
  }

  Future<bool> getPermission(Permission permission) async {
    final PermissionStatus status = await permission.request();
    if (!status.isGranted) {
      // await openAppSettings();
      return await permission.request().isGranted;
    }
    return status.isGranted;
  }

  /// 获取定位权限
  Future<bool> get getPermissions async {
    if (!await getPermission(Permission.location)) {
      return false;
    }
    return true;
  }

  Future<void> getLocation() async {
    if (!await getPermissions) return;
    final location = await FlAMapLocation().getLocation(true);
    debugPrint('getLocation===============>: ${location?.toMap()}');
    if (location != null) {
      _locationModel?.fromMap(location.toMap());
    }
  }

  /// 初始化定位
  Future<void> initLocation() async {
    if (!await getPermissions) return;
    await FlAMapLocation().initialize(AMapLocationOption());
    getLocation();
  }

  // 连续定位
  Future<void> startLocationState() async {
    if (!await getPermissions) return;
    final bool data = await FlAMapLocation().startLocationChanged(
        onLocationChanged: (AMapLocation location) {
      debugPrint('startLocationState================>: $location');
    });
  }

  void _bottomNavBarOnTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: tabPages[_currentPageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedLabelStyle:
            TextStyle(color: Theme.of(context).unselectedWidgetColor),
        items: bottomNavBarItems,
        currentIndex: _currentPageIndex,
        onTap: _bottomNavBarOnTap,
      ),
    );
  }
}
