import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import './home/home_page.dart';
import './community/community_view.dart';
import './personal/personal_view.dart';
import '../models/location_model.dart';
import './bluetooth/crowd_net.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ///蓝牙相关API
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  /// 页面
  late PageController _pageController;
  late LocationModel _locationModel;
  int _currentPageIndex = 0;
  List<Widget> tabPages = const [
    HomePage(),
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
    _pageController =
        PageController(initialPage: _currentPageIndex, keepPage: true);
    FlutterNativeSplash.remove();
    initializeBluetoothAdapter();
    // 开启人群网络搜索
    CrowdNet.startCrowNetwork();
  }

  @override
  void dispose() {
    _locationModel.dispose();
    _pageController.dispose();
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: tabPages,
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   showUnselectedLabels: true,
      //   unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      //   selectedItemColor: Theme.of(context).primaryColor,
      //   unselectedLabelStyle:
      //       TextStyle(color: Theme.of(context).unselectedWidgetColor),
      //   items: bottomNavBarItems,
      //   currentIndex: _currentPageIndex,
      //   onTap: _bottomNavBarOnTap,
      // ),
    );
  }

  void _bottomNavBarOnTap(int index) {
    setState(() {
      _currentPageIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  // 初始化蓝牙适配器
  Future initializeBluetoothAdapter() async {
    try {
      /// 检查设备是否支持蓝牙
      final isSupported = await FlutterBluePlus.isSupported;
      debugPrint('FlutterBluePlus.isSupported: $isSupported');
      if (!isSupported) {
        debugPrint('当前设备不支持蓝牙协议');
        return;
      }

      final adapterStateNow = FlutterBluePlus.adapterStateNow;
      debugPrint('FlutterBluePlus.adapterStateNow: $adapterStateNow');

      /// 监听蓝牙适配器状态
      _adapterStateStateSubscription = FlutterBluePlus.adapterState
          .listen((BluetoothAdapterState state) async {
        debugPrint('FlutterBluePlus.adapterState: $state');
        if (state == BluetoothAdapterState.on) {
          /// 尝试搜索，用以调起蓝牙授权
          try {
            await FlutterBluePlus.startScan();
            FlutterBluePlus.stopScan();
          } catch (e) {}
        }
        _adapterState = state;
        setState(() {});
      });
    } catch (e) {
      debugPrint('FlutterBluePlus.adapterState.listen Error: $e');
    }
  }
}
