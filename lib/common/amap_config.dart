import 'package:amap_flutter_base/amap_flutter_base.dart';

class AMapConfig {
  factory AMapConfig() => _singleton ??= AMapConfig._();
  AMapConfig._();
  static AMapConfig? _singleton;

  static AMapApiKey apiKey = const AMapApiKey(
    iosKey: 'f10d6b1d907e53d9e7e5e0a14a99c224',
    androidKey: '44617b96965472ca5b90e8a737e963f0',
  );
}
