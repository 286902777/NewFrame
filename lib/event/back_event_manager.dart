import 'dart:io';
import 'dart:ui';

import 'package:applovin_max/applovin_max.dart' hide NativeAdListener;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frame/event/http_manager.dart';
import 'package:frame/source/app_key.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../source/Common.dart';

enum BackEventName {
  advProfit('ababdeh'),
  playVideo('jacals'),
  viewApp('98ct2h0u1s'),
  downApp('rine'),
  appAdvProfit('mythopeic'),
  appPlayVideo('aesthesics'),
  newUserActiveByPlayVideo('quidnuncs'),
  downloadAppFirstTimeOpen('cacoepist');

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
    String unique_id = '';

    if (Platform.isIOS) {
      final storage = FlutterSecureStorage();
      String? uniqueId = await storage.read(key: 'app_unique_id');
      if (uniqueId != null) {
        unique_id = uniqueId;
      } else {
        unique_id = Uuid().v4();
        storage.write(key: 'app_unique_id', value: unique_id);
      }
    }
    PackageInfo info = await PackageInfo.fromPlatform();
    String deviceVersion = '';
    String deviceModel = '';
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceVersion = iosInfo.systemVersion;
      deviceModel = iosInfo.modelName;
    } else {
      final andInfo = await deviceInfo.androidInfo;
      deviceVersion = andInfo.version.release;
      deviceModel = andInfo.model;
    }

    try {
      HttpManager.eventPostRequest(
        source,
        para: {
          'updater': {'corsac': app_Bunlde_Id},
          'enlinkment': 'ios',
          'interhyal': Uuid().v1(), //log_id
          'leftists': linkId,
          'tortricid': userId,
          'ogtiern': value,
          'skirting': 'USD',
          'dictyonine': event.name,
          'vvi5bscptl': {'aphra': eventSource.name},
          'outclasses': unique_id,

          /// unique_id
          'wisure': info.version,
          'euryscope': deviceVersion,
          '1emejsbrma': {
            'handy': {'cowbell': deviceModel},
          }, ////1emejsbrma/handy/cowbell
          'nontitle': window.locale.languageCode,
          'turbanwise': DateTime.now().millisecondsSinceEpoch,
          'gsmmdbxvzj': fileId,
        },
        successHandle: (data) {
          if (data != null) {
            if (event == BackEventName.downApp) {
              AppKey.save(AppKey.appDeepNewUser, true);
            }
            if (event == BackEventName.downloadAppFirstTimeOpen) {
              AppKey.save(AppKey.appNewUser, true);
            }
          }
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            addEvent(event, source, value, linkId, userId, fileId);
          }
        },
      );
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void getAdsValue(
    BackEventName event,
    PlatformType source,
    dynamic ad,
    String linkId,
    String userId,
    String fileId,
  ) {
    if (ad is MaxAd) {
      addEvent(event, source, ad.revenue * 1000000, linkId, userId, fileId);
    }
    // if (ad is AdWithoutView) {
    //   ad.onPaidEvent = (
    //       Ad ad,
    //       double value,
    //       PrecisionType precision,
    //       String code,
    //       ) {
    //     addEvent(event, source, value, linkId, userId, fileId);
    //   };
    else if (ad is NativeAd) {
      BackEventManager.instance.ad_event = event;
      BackEventManager.instance.ad_source = source;
      BackEventManager.instance.ad_linkId = linkId;
      BackEventManager.instance.ad_userId = userId;
      BackEventManager.instance.ad_fileId = fileId;
    }
  }
}
