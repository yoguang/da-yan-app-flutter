import 'dart:ui';

import 'package:da_yan_app/pages/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import 'map_view.dart' show MapView;
import '../bluetooth/device_list.dart' show DeviceListWidget, Device;
import '../bluetooth/device_pairing_widget.dart' show DevicePairing;
import '../../utils/local_storage.dart' show LocalStorage;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  List<Device> data = [];
  late final LocalStorage localStorage = LocalStorage();
  SheetController controller = SheetController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('localStorage accessToken: ${localStorage.get('accessToken')}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SnappingBottomSheet(
                controller: controller,
                color: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 12,
                cornerRadius: 16,
                cornerRadiusOnFullscreen: 16,
                closeOnBackdropTap: false,
                closeOnBackButtonPressed: false,
                addTopViewPaddingOnFullscreen: false,
                isBackdropInteractable: false,
                snapSpec: SnapSpec(
                  initialSnap: 0.5,
                  snap: true,
                  positioning: SnapPositioning.relativeToAvailableSpace,
                  snappings: const [
                    SnapSpec.headerFooterSnap,
                    0.5,
                    0.99,
                  ],
                  onSnap: (state, snap) {
                    debugPrint('Snapped to $snap');
                  },
                ),
                parallaxSpec: const ParallaxSpec(
                  enabled: false,
                  amount: 0.35,
                  endExtent: 0.6,
                ),
                liftOnScrollHeaderElevation: 12.0,
                liftOnScrollFooterElevation: 12.0,
                body: _buildBody(),
                headerBuilder: buildHeader,
                // footerBuilder: buildFooter,
                // builder: buildChild,
                customBuilder: buildInfiniteChild,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return const Stack(
      children: <Widget>[
        MapView(),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Padding(
        //     padding: EdgeInsets.fromLTRB(
        //       0,
        //       MediaQuery.of(context).padding.top + 16,
        //       16,
        //       0,
        //     ),
        //     child: FloatingActionButton(
        //       backgroundColor: Colors.white,
        //       onPressed: () {
        //         // 定位当前位置

        //       },
        //       child: const Icon(
        //         Icons.my_location,
        //         color: Colors.blue,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

// BottomSheet 头部
  Widget buildHeader(BuildContext context, SheetState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 8)),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 28,
              height: 4,
              color: Colors.grey[400],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '设备',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  final token = localStorage.get('accessToken');
                  if (token == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                    return;
                  }
                  await showBottomSheetDialog(context);
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context, SheetState state) {
    Widget button(
      Icon icon,
      Text text,
      VoidCallback onTap, {
      BorderSide? border,
    }) {
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          const SizedBox(width: 8),
          text,
        ],
      );

      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );

      return border == null
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(shape: shape),
              child: child,
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(shape: shape),
              child: child,
            );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          button(
            const Icon(
              Icons.navigation,
              color: Colors.white,
            ),
            const Text(
              'Start',
            ),
            () async {
              // Inherit from context...
              await SheetController.of(context)?.hide();
              Future.delayed(
                const Duration(milliseconds: 1500),
                () {
                  // or use the controller
                  controller.show();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          SheetListenerBuilder(
            buildWhen: (oldState, newState) =>
                oldState.isExpanded != newState.isExpanded,
            builder: (context, state) {
              final isExpanded = state.isExpanded;

              return button(
                Icon(
                  !isExpanded ? Icons.list : Icons.map,
                  color: Colors.blue,
                ),
                Text(
                  !isExpanded ? 'Steps & more' : 'Show map',
                ),
                !isExpanded
                    ? () => controller.scrollTo(state.maxScrollExtent)
                    : controller.collapse,
                border: BorderSide(
                  color: Colors.grey.shade400,
                  width: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildChild(BuildContext context, SheetState state) {
    return ListView.separated(
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text('$index'),
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: 10,
    );
  }
}

Widget buildInfiniteChild(
  BuildContext context,
  ScrollController controller,
  SheetState state,
) {
  // return SingleChildScrollView(
  //   controller: controller,
  //   child: const DeviceListWidget(devicesData: []),
  // );
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
    child: SingleChildScrollView(
      controller: controller,
      child: const DeviceListWidget(devicesData: []),
    ),
  );
}

Future<void> showBottomSheetDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;

  final controller = SheetController();
  bool isDismissable = false;

  await showSnappingBottomSheet(
    context,
    // parentBuilder: (context, sheet) {
    //   return Theme(
    //     data: ThemeData.dark(),
    //     child: sheet,
    //   );
    // },
    builder: (context) {
      return SnappingBottomSheetDialog(
        // 控制工作表状态的控制器。
        controller: controller,
        // 工作表的基本动画持续时间。滑动和甩动的持续时间可能不同。
        duration: const Duration(milliseconds: 500),
        // [SnapSpec] 定义工作表应如何对齐或是否应该对齐。
        snapSpec: const SnapSpec(
          snap: true,
          initialSnap: 0.5,
          snappings: [
            0.5,
          ],
        ),
        // scrollSpec: const ScrollSpec(
        //   showScrollbar: true,
        // ),
        color: Colors.white,
        maxWidth: double.infinity,
        minHeight: MediaQuery.of(context).size.height / 2,
        // 如果为false，则SnappingBottomSheetDialog不会被解雇。这意味着用户将无法使用手势或后退按钮关闭工作表。
        isDismissable: true,
        // 如果为 true，则该工作表将被取消背景 被窃听了。
        dismissOnBackdropTap: true,
        // 如果为 true，则 backDrop 也将是可交互的，因此任何手势 应用于 backDrop 的将被委托给工作表 本身。
        isBackdropInteractable: true,
        // 当用户尝试关闭对话框时调用的回调 而 [isDimissable] 设置为true.
        //  The backButton标志指示用户是否尝试关闭工作表 使用后退按钮，而backDrop表示用户是否尝试过 通过点击背景来关闭工作表。
        onDismissPrevented: (backButton, backDrop) async {
          debugPrint('onDismissPrevented--------->');
          if (backButton || backDrop) {
            const duration = Duration(milliseconds: 300);
            await controller.snapToExtent(0.2,
                duration: duration, clamp: false);
            await controller.snapToExtent(0.4, duration: duration);
            // or Navigator.pop(context);
          }

          // Or pop the route
          if (backButton) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Material(
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  right: 20,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const DevicePairing(),
              ],
            ),
          );
        },
      );
    },
  );
}
