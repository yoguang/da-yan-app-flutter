/// 计算两个时间差 返回格式化字符串
String dateTimerDifferenceToString(String time1, String time2) {
  final t1 = DateTime.parse(time1);
  final t2 = DateTime.parse(time2);
  final diff = t2.difference(t1);
  if (diff.inDays >= 1) {
    return "${diff.inDays}天前";
  } else if (diff.inHours >= 1) {
    return "${diff.inHours}小时前";
  } else if (diff.inMinutes >= 1) {
    return "${diff.inMinutes}分钟前";
  } else if (diff.inSeconds > 30) {
    return "刚刚";
  }
  return "现在";
}
