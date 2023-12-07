import 'package:flutter/material.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';

import '../widgets/map_view.dart';
import '../widgets/location.dart';
import '../widgets/device_list.dart';

const deviceDataMock = [
  {
    'deviceId': '2334343344343',
    'name': '书包',
    'address': '北京市海淀区中关村北一条科源社区',
    'distance': '1米',
    "latitude": 39.9871689,
    "longitude": 116.3140698,
  },
  {
    'deviceId': '2334343344343',
    'name': '自行车',
    'address': '北京市海淀区中关村北一条',
    'distance': '4米',
    "latitude": 39.9871689,
    "longitude": 116.3150698,
  },
  {
    'deviceId': '2334343344343',
    'name': '钱包',
    'address': '北京市海淀区中关村',
    'distance': '8米',
    "latitude": 39.9871689,
    "longitude": 116.3160698,
  },
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Device> data = [];

  @override
  void initState() {
    super.initState();
    data.addAll(deviceDataMock.map((e) => Device.fromJson(e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Center(
          child: MapView(),
        ),
      ),
      bottomSheet: InteractiveBottomSheet(
        options: const InteractiveBottomSheetOptions(
          maxSize: 0.93,
          backgroundColor: Colors.white,
          snapList: [0.25, 0.5],
        ),
        draggableAreaOptions: const DraggableAreaOptions(
          topBorderRadius: 18,
          height: 45,
          backgroundColor: Colors.white, // 拖拽区域颜色
          indicatorColor: Colors.grey, // 指示器颜色
          indicatorWidth: 50, // 指示器宽度
          indicatorHeight: 5, // 指示器高度
          indicatorRadius: 5, // 指示器圆角
        ),
        child: DeviceListWidget(devicesData: data),
      ),
    );
  }
}
