import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import '/pages/login/login_view.dart';
import 'bluetooth_model.dart';
import 'device_pairing_widget.dart';

import '/utils/local_storage.dart';

class DeviceAddButton extends StatelessWidget {
  DeviceAddButton({
    super.key,
    this.icon,
    this.text,
  });
  final Icon? icon;
  final Text? text;
  final LocalStorage localStorage = LocalStorage();

  void handleAdd(context) async {
    final token = localStorage.get('accessToken');
    if (token == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      ).then((isLogin) async {
        if (isLogin == null) return;
        final bleModel =
            Provider.of<BluetoothDeviceModel>(context, listen: false);
        bleModel.getDevice();
      });
      return;
    } else {
      await showBottomSheetDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return TextButton(onPressed: () => handleAdd(context), child: text!);
    } else {
      return IconButton(
        onPressed: () => handleAdd(context),
        icon: icon ??
            Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            ),
        iconSize: 28,
      );
    }
  }

  Future<void> showBottomSheetDialog(BuildContext context) async {
    SheetController controller = SheetController();

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
            snappings: [0.5],
          ),
          color: Colors.white,
          maxWidth: double.infinity,
          minHeight: MediaQuery.of(context).size.height / 2,
          builder: (context, state) {
            return Material(
              color: Colors.white,
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
}
