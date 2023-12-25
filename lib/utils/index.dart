class Utils {
  /// 从 [Enum] 返回一个 [String]
  static String? enumToString(o) {
    if (o == null) return null;
    return o.toString().split('.').last;
  }

  /// 从 [String] 返回一个 [Enum]
  static T enumFromString<T>(Iterable<T> values, String? value) {
    return values
        .firstWhere((type) => type.toString().split('.').last == value);
  }
}
