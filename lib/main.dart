import 'package:flutter/material.dart';
import 'package:fl_amap_map/fl_amap_map.dart';
import './pages/home_page.dart';
import './pages/community_page.dart';
import './pages/my_page.dart';
import './pages/bottom_sheet_view.dart';
import './widgets/map_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  runApp(const MyApp());
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  List<Widget> tabPages = const [
    HomePage(),
    CommunityPage(),
    MapView(),
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
      icon: Icon(Icons.my_library_books),
      label: '我的',
    ),
  ];

  void _bottomNavBarOnTap(int index) {
    print('index: $index');
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
        items: bottomNavBarItems,
        currentIndex: _currentPageIndex,
        onTap: _bottomNavBarOnTap,
      ),
    );
  }
}
