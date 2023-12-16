import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceNamePicker extends StatefulWidget {
  const DeviceNamePicker({super.key, required this.onOk});
  final ValueChanged<String> onOk;

  @override
  State<DeviceNamePicker> createState() => _DeviceNamePickerState();
}

class _DeviceNamePickerState extends State<DeviceNamePicker> {
  final double _kItemExtent = 32.0;
  final List<String> _deviceNames = <String>[
    '背包',
    '钥匙',
    '钱包',
    '伞',
    '自行车',
    '自定义命名',
  ];
  int _selectedIndex = 2;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _deviceNames[_selectedIndex];
  }

  void handleOk(BuildContext context) {
    widget.onOk(_nameController.text);
    return;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_nameController: ${_nameController.text}');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 18),
            child: Text(
              '设置名称',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: _kItemExtent,
              // //设置初始项。
              scrollController: FixedExtentScrollController(
                initialItem: _selectedIndex,
              ),
              // 当所选项目更改时调用此方法。
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selectedIndex = selectedItem;
                  _nameController.text = _deviceNames[selectedItem];
                });
              },
              children: List<Widget>.generate(_deviceNames.length, (int index) {
                return Center(child: Text(_deviceNames[index]));
              }),
            ),
          ),
          // 选中自定义命名, 显示输入框
          if (_selectedIndex == 5)
            SizedBox(
              width: 300,
              height: 48,
              child: TextField(
                controller: _nameController,
              ),
            ),
          if (_selectedIndex != 5)
            const SizedBox(
              height: 48,
            ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => handleOk(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
