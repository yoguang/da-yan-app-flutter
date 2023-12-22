// /// 百度地图
// import 'dart:developer';
// import 'dart:io' show Platform;

// import 'package:flutter/material.dart';
// import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
// import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

// class BDMapViewWidget extends StatefulWidget {
//   const BDMapViewWidget({super.key});

//   @override
//   State<BDMapViewWidget> createState() => _BDMapViewWidgetState();
// }

// class _BDMapViewWidgetState extends State<BDMapViewWidget> {
//   @override
//   void initState() {
//     super.initState();
//     _initMap();
//   }

//   void _initMap() {
//     // 设置是否隐私政策
//     BMFMapSDK.setAgreePrivacy(true);
//     if (Platform.isIOS) {
//       /// 设置ios端ak, android端ak可以直接在清单文件中配置
//       BMFMapSDK.setApiKeyAndCoordType(
//         'uK3B94FoxhOB07Gnu8bSexbAQovK7QXT',
//         BMF_COORD_TYPE.BD09LL,
//       );
//     }
//   }

//   void _onMapCreated(BMFMapController controller) {
//     print('BMFMapController: ');
//     print(controller);
//   }

//   BMFMapOptions mapOptions = BMFMapOptions(
//     center: BMFCoordinate(39.917215, 116.380341),
//     zoomLevel: 12,
//     // mapPadding: BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       child: BMFMapWidget(
//         onBMFMapCreated: (controller) {
//           _onMapCreated(controller);
//         },
//         mapOptions: mapOptions,
//       ),
//     );
//   }
// }
