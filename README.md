# 大雁APP

基于Flutter实现的一款BLE低功耗蓝牙定位查找应用程序。集成高德SDK，实现地图显示，以及定位功能。

## Flutter 入门

如果这是你的第一个Flutter项目，有一些资源可以帮助你开始：
- [编写你的第一个Flutter应用](https://flutter.cn/docs/get-started/codelab)
- [有用的Flutter样本](https://docs.flutter.dev/cookbook)

有关Flutter开发入门的帮助，请查看 [在线文档](https://flutter.cn/docs), 提供教程， 示例、移动的开发指南和完整的API参考。

## 打包

> 分平台打包 armeabi-v7a、arm64-v8a、x86_64
```bash
flutter build apk --split-per-abi
```

## 启动图标设置

> 安装 flutter_launcher_icons 插件
```csharp
 flutter pub add dev:flutter_launcher_icons
```
> 添加配置信息，打开 pubspec.yaml
```yaml
flutter_icons:
  image_path: "assets/launch/logo.png"
  android: true 
  ios: true 
```
> 执行创建命令，注意：每次替换图标需要重新执行该命令
```csharp
flutter pub run flutter_launcher_icons:main
```
### 注意事项
___
Format: 32-bit PNG

icon 大小必须是  1024x1024

确保在 40px 大小时也能清晰可见，这是 icon 最小的尺寸。

icon 不能大于 1024KB

icon 不能是透明的。

必须是正方形，不能有圆角。

icon 的边可能会被切掉，因为 Icon 最后展示的可能不是正方形，所以一般边上需要留白。
___