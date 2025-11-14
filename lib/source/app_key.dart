import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppKey {
  static const clickCommendStar = 'osaclickCommendStar';

  static const numCommend = 'osanumCommend';

  static const commendTime = 'osacommendTime';

  static const commentPlayCount = 'osacommentPlayCount';

  static const onceInstallApp = 'osaonceInstallApp';

  static const isFirstLink = 'osaisFirstLink';

  static const appLinkId = 'osaappLinkId';

  static const appUserId = 'osaappUserId';

  static const appNewUser = 'osaappNewUser';

  static const showSpeedVideo = 'osashowSpeedVideo';

  static const showNum = 'osashowNum';

  static const showRate = 'osashowRate'; //间隔三个视频

  static const vipAlertShowCount = 'osavipAlertShowCount';

  static const vipAlertPlayTime = 'osavipAlertPlayTime';

  static const vipAlertTime = 'osavipAlertTime';

  static const vipPlayCount = 'osavipPlayCount'; //成功展示2次广告后，关闭广告展示弹窗；

  static const isVipUser = 'osaisVipUser';

  static const vipProductId = 'osavipProductId';

  static const appNewUserPlay = 'osaappNewUserPlay';

  static const appInstall = 'osaappInstall';

  static const openDeepInstall = 'osaopenDeepInstall';

  static const eventList = 'osaeventList';

  static const email = 'osaemail';

  static const toDay = 'osatoDay';

  static Future<bool> save(String key, dynamic value) async {
    SharedPreferences ns = await SharedPreferences.getInstance();
    if (value is Map) {
      var v = jsonEncode(value);
      return ns.setString(key, v);
    } else if (value is int) {
      return ns.setInt(key, value);
    } else if (value is double) {
      return ns.setDouble(key, value);
    } else if (value is bool) {
      return ns.setBool(key, value);
    } else if (value is String) {
      return ns.setString(key, value);
    } else {
      return ns.setString(key, value.toString());
    }
  }

  static Future<String?> getString(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    String? value = user.getString(key);
    return value;
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    bool? value = user.getBool(key);
    return value;
  }

  static Future<int?> getInt(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    int? value = user.getInt(key);
    return value;
  }

  static Future<double?> getDouble(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    double? value = user.getDouble(key);
    return value;
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    SharedPreferences ns = await SharedPreferences.getInstance();
    String? value = ns.getString(key);
    if (value != null) {
      Map<String, dynamic>? map = jsonDecode(value);
      return map;
    }
    return null;
  }
}
