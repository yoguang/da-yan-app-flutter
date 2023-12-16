import 'package:flutter/cupertino.dart';

import './request.dart';

class Api {
  // 登录
  static login(data) {
    return Request.post(
      "/user/login",
      data: data,
    );
  }

  // 注册账号
  static signup(data) {
    return Request.post(
      "/user/signup",
      data: data,
    );
  }

  // 获取用户已绑定设备
  static getBoundDevice() {
    return Request.get(
      "/device/getDevice",
    );
  }

  // 配对连接新的设备
  static connect(data) {
    return Request.post(
      "/device/connect",
      data: data,
    );
  }

  // 更新设备定位
  static updateLocation(data) {
    return Request.post(
      "/device/updateLocation",
      data: data,
    );
  }

  // 获取标记丢失的设备
  static getLoseDevice() {
    return Request.get(
      "/device/getLoseDevice",
    );
  }
}
