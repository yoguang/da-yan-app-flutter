import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bottom_sheet/bottom_sheet.dart' show showFlexibleBottomSheet;

class BotSheetView extends StatefulWidget {
  const BotSheetView({super.key});

  @override
  State<BotSheetView> createState() => _BotSheetViewState();
}

class _BotSheetViewState extends State<BotSheetView> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      showFlexibleBottomSheet(
        minHeight: 0.2,
        initHeight: 0.5,
        maxHeight: 1,
        context: context,
        builder: _buildBottomSheet,
        anchors: [0.2, 0.5, 1],
        isSafeArea: true,
        isModal: false,
        isCollapsible: false,
        isDismissible: false,
      );
    });
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
  ) {
    return Material(
      child: Container(
        child: ListView(
          controller: scrollController,
          children: const [Text('data')],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('哇哈哈'),
      ),
    );
  }
}
