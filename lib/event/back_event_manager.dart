import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frame/source/app_key.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../source/Common.dart';

enum BackEventName {
  advProfit('oldstsdyle'),
  playVideo('lor12eless'),
  viewApp('swimbsfel'),
  downApp('jacobsbson'),
  appAdvProfit('slackxsening'),
  appPlayVideo('cynesdbot'),
  newUserActiveByPlayVideo('vindiasdcate');

  final String name;
  const BackEventName(this.name);
}

class BackEventManager {
  static final BackEventManager instance = BackEventManager();
  static final String uuId = Uuid().v1();

  BackEventName ad_event = BackEventName.advProfit;
  PlatformType ad_source = PlatformType.india;
  double ad_value = 0.0;
  String ad_linkId = '';
  String ad_userId = '';
  String ad_fileId = '';

  void addEvent(
    BackEventName event,
    PlatformType source,
    double value,
    String linkId,
    String userId,
    String fileId,
  ) async {
    // String uuId = '';
    //
    // if (Platform.isIOS) {
    //   final storage = FlutterSecureStorage();
    //   String? uniqueId = await storage.read(key: 'unique_id');
    //   if (uniqueId != null) {
    //     uuId = uniqueId;
    //   } else {
    //     uuId = Uuid().v4();
    //     storage.write(key: 'unique_id', value: uuId);
    //   }
    // }
    // PackageInfo info = await PackageInfo.fromPlatform();
    // String deviceVersion = '';
    // String? locale = await Devicelocale.currentLocale;
    // String deviceModel = '';
    // final deviceInfo = DeviceInfoPlugin();
    // if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   deviceVersion = iosInfo.systemVersion;
    //   deviceModel = iosInfo.modelName;
    // } else {
    //   final andInfo = await deviceInfo.androidInfo;
    //   deviceVersion = andInfo.version.release;
    //   deviceModel = andInfo.model;
    // }
    //
    // try {
    //   ServiceClentManager.eventPostRequest(
    //     source,
    //     para: {
    //       'decanally': {'orbitele': appBunldeId},
    //       'chiliadal': 'ios',
    //       'ishxttblpj': Uuid().v1(), //111111
    //       'robbed': linkId,
    //       'cricking': userId,
    //       'mithra': value,
    //       'compeering': 'USD',
    //       'darvon': event.name,
    //       'cradock': {'pamphilius': eventSource.name},
    //       'airmailing': uuId,
    //       'copiously': info.version,
    //       'rebunker': deviceVersion,
    //       'bilovlf847': locale ?? '',
    //       'inkhornize': {
    //         'sithes': {'outplans': deviceModel},
    //       },
    //       'exies': window.locale.languageCode,
    //       'jeroboams': DateTime.now().millisecondsSinceEpoch,
    //       'colitis': fileId,
    //     },
    //     successHandle: (data) {
    //       if (data != null) {
    //         if (event == BackEventName.downApp) {
    //           AppKey.save(AppKey.appNewUser, true);
    //         }
    //         print('object');
    //       }
    //     },
    //     failHandle: (refresh, code, msg) {
    //       if (refresh) {
    //         addEvent(event, source, value, linkId, userId, fileId);
    //       }
    //     },
    //   );
    // } catch (e) {
    //   print('${e.toString()}');
    // }
  }

  void getAdsValue(
    BackEventName event,
    PlatformType source,
    dynamic ad,
    String linkId,
    String userId,
    String fileId,
  ) {
    // if (ad is MaxAd) {
    //   addEvent(event, source, ad.revenue * 1000000, linkId, userId, fileId);
    // }
    // if (ad is AdWithoutView) {
    //   ad.onPaidEvent = (
    //       Ad ad,
    //       double value,
    //       PrecisionType precision,
    //       String code,
    //       ) {
    //     addEvent(event, source, value, linkId, userId, fileId);
    //   };
    // } else if (ad is NativeAd) {
    //   ServiceEvent.instance.ad_event = event;
    //   ServiceEvent.instance.ad_source = source;
    //   ServiceEvent.instance.ad_linkId = linkId;
    //   ServiceEvent.instance.ad_userId = userId;
    //   ServiceEvent.instance.ad_fileId = fileId;
    // }
  }
}
