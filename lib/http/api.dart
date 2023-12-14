import './request.dart';

class Api {
  // 登录
  static login(data) {
    return Request.get(
      "/user/login",
    );
  }
}
