// import 'package:flutter/material.dart';
// import 'package:amap_flutter_map/amap_flutter_map.dart';
// import 'package:amap_flutter_base/amap_flutter_base.dart';

// class AMapViewWidget extends StatefulWidget {
//   const AMapViewWidget({super.key});

//   @override
//   State<AMapViewWidget> createState() => _AMapViewWidgetState();
// }

// class _AMapViewWidgetState extends State<AMapViewWidget> {
//   ///建议在APP首次启动或者进行弹窗进行隐私声明时，根据用户设置
//   ///
//   /// [hasContains] 隐私权政策是否包含高德开平隐私权政策
//   ///
//   ///[hasShow] 隐私权政策是否弹窗展示告知用户
//   ///
//   ///[hasAgree] 隐私权政策是否已经取得用户同意
//   static const AMapPrivacyStatement amapPrivacyStatement =
//       AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);

//   ///先将申请的Android端可以和iOS端key设置给AMapApiKey
//   static const AMapApiKey amapApiKeys = AMapApiKey(
//     androidKey: '44617b96965472ca5b90e8a737e963f0',
//     iosKey: 'f10d6b1d907e53d9e7e5e0a14a99c224',
//   );

//   static const CameraPosition _kInitialPosition = CameraPosition(
//     target: LatLng(39.909187, 116.397451),
//     zoom: 16.0,
//   );
//   final List<Widget> _approvalNumberWidget = [];

//   @override
//   Widget build(BuildContext context) {
//     // final AMapWidget map = AMapWidget(
//     //   initialCameraPosition: _kInitialPosition,
//     //   onMapCreated: onMapCreated,
//     // );

//     return ConstrainedBox(
//       constraints: const BoxConstraints.expand(),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: const AMapWidget(
//               apiKey: amapApiKeys,
//               initialCameraPosition: _kInitialPosition,

//               ///必须正确设置的合规隐私声明，否则SDK不会工作，会造成地图白屏等问题。
//               privacyStatement: amapPrivacyStatement,
//             ),
//           ),
//           Positioned(
//               right: 10,
//               bottom: 15,
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: _approvalNumberWidget),
//               ))
//         ],
//       ),
//     );
//   }

//   late AMapController _mapController;
//   void onMapCreated(AMapController controller) {
//     setState(() {
//       _mapController = controller;
//       getApprovalNumber();
//     });
//   }

//   /// 获取审图号
//   void getApprovalNumber() async {
//     //普通地图审图号
//     String? mapContentApprovalNumber =
//         await _mapController.getMapContentApprovalNumber();
//     //卫星地图审图号
//     String? satelliteImageApprovalNumber =
//         await _mapController.getSatelliteImageApprovalNumber();
//     setState(() {
//       if (null != mapContentApprovalNumber) {
//         _approvalNumberWidget.add(Text(mapContentApprovalNumber));
//       }
//       if (null != satelliteImageApprovalNumber) {
//         _approvalNumberWidget.add(Text(satelliteImageApprovalNumber));
//       }
//     });
//     print('地图审图号（普通地图）: $mapContentApprovalNumber');
//     print('地图审图号（卫星地图): $satelliteImageApprovalNumber');
//   }
// }
