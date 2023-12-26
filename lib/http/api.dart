import './request.dart';

class Api {
  /// 登录
  static login(data) {
    return Request.post(
      "/user/login",
      data: data,
    );
  }

  /// 注册账号
  static signup(data) {
    return Request.post(
      "/user/signup",
      data: data,
    );
  }

  /// 获取用户已绑定设备
  static getBoundDevice() {
    return Request.get(
      "/device/getDevice",
    );
  }

  /// 配对连接新的设备
  static connect(data) {
    return Request.post(
      "/device/connect",
      data: data,
    );
  }

  /// 更新设备定位
  static updateLocation(Map data) {
    return Request.post(
      "/device/updateLocation",
      data: data,
    );
  }

  /// 获取标记丢失的设备
  static getLoseDevice() {
    return Request.get(
      "/device/getLoseDevice",
    );
  }

  /// 标记丢失
  /// {String deviceId}
  /// {bool isLose}
  static updateLoseStatus(Map data) {
    return Request.put(
      "/device/updateLoseStatus",
      data: data,
    );
  }

  /// 重命名
  /// {String deviceId}
  /// {String name}
  static rename(Map data) {
    return Request.put(
      "/device/rename",
      data: data,
    );
  }

  /// {String deviceId}
  static delete(Map data) {
    return Request.delete(
      "/device/delete",
      data: data,
    );
  }
}
