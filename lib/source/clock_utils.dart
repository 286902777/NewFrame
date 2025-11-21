import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';

class ClockUtils {
  static bool get isPad {
    final mediaQuery = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final size = mediaQuery.size;
    return size.shortestSide >= 600;
  }

  static bool get isVpn {
    // final status = await VpnDetector().isVpnActive();
    // return status;
    return false;
  }

  static Future<bool> isEmulator() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      } else {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isSimCard() async {
    // final hasSim = await SimReader.hasSimCard();
    // return hasSim;
    return false;
  }
}
