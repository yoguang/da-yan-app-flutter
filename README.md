# 大雁APP

基于Flutter实现的一款BLE低功耗蓝牙定位查找应用程序。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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