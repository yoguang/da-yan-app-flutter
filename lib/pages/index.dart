import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
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

  /// 底部导航栏相关状态
  var _showMessageBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationModel = Provider.of<LocationModel>(context, listen: false);
    _pageController =
        PageController(initialPage: _currentPageIndex, keepPage: true);
    FlutterNativeSplash.remove();
    requestPermission();
    initializeBluetoothAdapter();
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
      //   items: generateBottomBarItems(),
      //   currentIndex: _currentPageIndex,
      //   onTap: _bottomNavBarOnTap,
      // ),
    );
  }

  getMessageBadgeStatus() {
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showMessageBadge = true;
      });
    });
  }

  generateBottomBarItems() {
    List<BottomNavigationBarItem> bottomNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.square_grid_2x2_fill),
        label: '设备',
      ),
      BottomNavigationBarItem(
        icon: Stack(children: <Widget>[
          const Icon(CupertinoIcons.bubble_left_bubble_right_fill),
          if (_showMessageBadge)
            const Positioned(
              top: 0.0,
              right: 0.0,
              child:
                  Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
            )
        ]),
        label: '通知',
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.person),
      //   label: '我的',
      // ),
    ];
    return bottomNavBarItems;
  }

  void _bottomNavBarOnTap(int index) {
    _currentPageIndex = index;
    _pageController.jumpToPage(index);
    if (index == 1) {
      _showMessageBadge = false;
    }
    setState(() {});
  }

  /// 请求系统权限
  Future<void> requestPermission() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      /// 获取当前的权限
      var isGranted = await Permission.bluetoothScan.isGranted;

      /// 判断是否授权，否发起授权
      if (isGranted) {
        CrowdNet.startCrowNetwork(context);
      }
    } catch (e) {
      debugPrint('requestPermission error-------------->$e');
    }
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
        if (state == BluetoothAdapterState.off) {
          if (context.mounted) {
            _showAlertDialog(context);
          }
          return;
        }

        if (state == BluetoothAdapterState.on) {
          /// 开启人群网络搜索
          // CrowdNet.startCrowNetwork(context);
        }

        _adapterState = state;
        setState(() {});
      });
    } catch (e) {
      debugPrint('FlutterBluePlus.adapterState.listen Error: $e');
    }
  }

  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("蓝牙未开启"),
        content: const Text(
          "请打开蓝牙，以获取完整功能。",
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
              Timer(const Duration(milliseconds: 60), () {
                /// 打开蓝牙开关
                FlutterBluePlus.turnOn();
              });
            },
            child: const Text(
              '打开',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        //  应用程序处于闲置状态并且没有收到用户的输入事件。
        //注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
        break;
      case AppLifecycleState.paused:
        // 应用程序处于不可见状态
        CrowdNet.startBackgroundTasks();
        break;
      case AppLifecycleState.resumed:
        // 进入应用时候不会触发该状态
        CrowdNet.stopBackgroundTasks();
        break;
      case AppLifecycleState.detached:
        //当前页面即将退出
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
