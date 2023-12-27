import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceNamePicker extends StatefulWidget {
  const DeviceNamePicker({super.key, required this.onOk, this.name});
  final ValueChanged<String> onOk;
  final String? name;

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
  final _nameTextEditController = TextEditingController();
  final _scrollController = FixedExtentScrollController(
    initialItem: 2,
  );

  /// 是否选择自定义
  bool _isSelectedIndex5 = false;

  @override
  void initState() {
    super.initState();
    _nameTextEditController.text = _deviceNames[_selectedIndex];
  }

  @override
  void didUpdateWidget(covariant DeviceNamePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSelectedIndex5) return;
    if (widget.name == null) return;
    final findIndex = _deviceNames.indexOf(widget.name as String);
    if (findIndex > -1) {
      _selectedIndex = findIndex;
    } else {
      _selectedIndex = _deviceNames.indexOf("自定义命名");
      _isSelectedIndex5 = _selectedIndex == 5;
    }
    _scrollController
        .animateToItem(
      _selectedIndex,
      duration: const Duration(microseconds: 1),
      curve: Curves.bounceInOut,
    )
        .then((value) {
      _nameTextEditController.text = widget.name as String;
    });
    setState(() {});
  }

  void handleOk() {
    widget.onOk(_nameTextEditController.text);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_nameTextEditController: ${_nameTextEditController.text}');

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
              // 设置初始项。
              scrollController: _scrollController,
              // 当所选项目更改时调用此方法。
              onSelectedItemChanged: (int selectedItem) {
                _selectedIndex = selectedItem;
                _isSelectedIndex5 = selectedItem == 5;
                late String newName = _deviceNames[selectedItem];
                if (widget.name != null) {
                  newName = (_isSelectedIndex5
                      ? widget.name
                      : _deviceNames[selectedItem])!;
                }
                _nameTextEditController.text = newName;
                setState(() {});
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
                controller: _nameTextEditController,
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
                  onPressed: handleOk,
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
