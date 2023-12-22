import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import './home/home_page.dart';
import './community/community_view.dart';
import './personal/personal_view.dart';
import '../models/location_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    initLocation();
    // CrowdNet.startCrowNetwork();
  }

  @override
  void dispose() {
    _locationModel.dispose();
    _pageController.dispose();
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
    // if (!await getPermissions) return;
    // final location = await FlAMapLocation().getLocation(true);
    // debugPrint('getLocation===============>: ${location?.toMap()}');
    // if (location != null) {
    //   _locationModel.fromMap(location.toMap());
    // }
  }

  /// 初始化定位
  Future<void> initLocation() async {
    // FlAMapLocation().initialize(onLocationChanged: (location) {
    //   debugPrint('连续定位----------------------$location');
    //   // _locationModel.fromMap(location.toMap());
    // });
  }

  void _bottomNavBarOnTap(int index) {
    setState(() {
      _currentPageIndex = index;
      _pageController.jumpToPage(index);
    });
  }
}
