import 'package:flutter/material.dart';

class DistanceIndicator extends StatelessWidget {
  DistanceIndicator({super.key, required this.distanceStatus});
  final int distanceStatus;
  final List<int> sizes = [30, 100, 180];

  @override
  Widget build(BuildContext context) {
    final size = sizes[distanceStatus].toDouble();
    return Center(
      child: AnimatedContainer(
        // 使用 State 类中存储的属性。
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size),
        ),
        // 定义动画需要多长时间。
        duration: const Duration(milliseconds: 500),
        // 提供可选的曲线，使动画感觉更流畅。
        curve: Curves.fastOutSlowIn,
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
