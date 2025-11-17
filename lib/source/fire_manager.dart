import 'dart:convert';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart'
    show
        FlutterError,
        FlutterErrorDetails,
        TargetPlatform,
        defaultTargetPlatform,
        kDebugMode,
        kIsWeb;
import 'package:frame/source/app_key.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../admob_max/admob_max_tool.dart';
import '../event/event_manager.dart';
import 'Common.dart';

class FireConfigKey {
  static String maxiOSConfigKey = 'ios_frame_ads';

  static String maxAndroidConfigKey = 'android_frame_ads';

  static String maxiOSPlusConfigKey = 'ios_frame_plus';

  static String maxAndroidPlusConfigKey = 'android_frame_plus';

  static String maxKey =
      'GfQnlat0NBNnAweifSxxL5Z5z8ILJg2xAqWoDCTnH1Mpk0HSeVtfFlzIeMTwr7HcIFtdOX6HmJGTsfaUIV_KON';
  // app打开等待时长
  static String appStartTime = 'appStartTime';
  // 播放多长时间开启广告
  static String playWaitKey = "playWaitKey";
  // 广告间隔时间
  static String adsTimeKey = 'adsTimeKey';
  // 原生广告显示时长
  static String nativeTimeKey = 'nativeTimeKey';
  // 原生广告关闭机率
  static String nativeClickKey = 'nativeClickKey';

  static String levelKey = 'Level_frame';

  static String typeKey = 'type_frame';

  static String sourceKey = 'source_frame';

  static String adsIdKey = 'Id_frame';

  // static String userFileName = 'premuim_Config_AB';
  //
  // static String userName = 'subscription_Info';
  //
  // static String user_product_id = 'product_id';
  // static String user_quantity = 'quantity';
  // static String user_index = 'order';
  // static String user_select = 'default_selected';
  // static String user_type = 'type';
}

class FireManager {
  static final FireManager instance = FireManager();

  // static Map userFile = {
  //   FireConfigKey.userName: [
  //     {
  //       FireConfigKey.user_product_id: 'lifetime_kreel',
  //       FireConfigKey.user_index: 0,
  //       FireConfigKey.user_quantity: true,
  //       FireConfigKey.user_select: true,
  //       FireConfigKey.user_type: 'Permanent',
  //     },
  //     {
  //       FireConfigKey.user_product_id: 'annual_kreel',
  //       FireConfigKey.user_index: 1,
  //       FireConfigKey.user_quantity: false,
  //       FireConfigKey.user_select: false,
  //       FireConfigKey.user_type: 'Yearly',
  //     },
  //     {
  //       FireConfigKey.user_product_id: 'weekly_kreel',
  //       FireConfigKey.user_index: 2,
  //       FireConfigKey.user_quantity: false,
  //       FireConfigKey.user_select: false,
  //       FireConfigKey.user_type: 'Weekly',
  //     },
  //   ],
  // };

  static Map adsFile = {
    FireConfigKey.appStartTime: 7,
    FireConfigKey.adsTimeKey: 60,
    FireConfigKey.nativeTimeKey: 7,
    FireConfigKey.nativeClickKey: 80,
    FireConfigKey.playWaitKey: 600,

    AdsSceneType.open.value: [
      {
        FireConfigKey.levelKey: 2,
        FireConfigKey.typeKey: AdsType.open.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '1a62f6256a2e0d0a',
      },
    ],
    AdsSceneType.play.value: [
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/9555844867',
      },
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04c3fcf8b00d56b4',
      },
    ],
    AdsSceneType.channel.value: [
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '3b3b3f6e3fad773b',
      },
    ],
    // MaxSceneType.plus.value: [
    //   {
    //     FireConfigKey.maxLevelKey: 5,
    //     FireConfigKey.maxTypeKey: MaxType.native.value,
    //     FireConfigKey.maxSourceKey: MaxSourceType.admob.value,
    //     FireConfigKey.maxIdKey: AdsUnitId.admobNativeAdsUnitId,
    //   },
    // ],
  };

  static Map adsPlusFile = {AdsSceneType.plus.value: []};

  static late FirebaseAnalyticsObserver observer;

  Future<void> addConfig() async {
    await Firebase.initializeApp(options: DefaultOptions.currentPlatform);
    FirebaseAnalytics analytic = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytic);

    FirebaseRemoteConfig remote = FirebaseRemoteConfig.instance;
    await remote.setDefaults(
      Platform.isIOS
          ? {FireConfigKey.maxiOSConfigKey: jsonEncode(adsFile)}
          : {FireConfigKey.maxAndroidConfigKey: jsonEncode(adsFile)},
    );

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordError(
        details,
        details.stack,
        fatal: true,
      );
    };

    updateRemoteSet() async {
      String mfile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSConfigKey
            : FireConfigKey.maxAndroidConfigKey,
      );
      String pfile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSPlusConfigKey
            : FireConfigKey.maxAndroidPlusConfigKey,
      );
      if (mfile.isNotEmpty) {
        adsFile = jsonDecode(mfile);
      }

      if (pfile.isNotEmpty) {
        adsPlusFile = jsonDecode(pfile);
      }

      if (adsFile[FireConfigKey.playWaitKey] != null) {
        AdmobMaxTool.instance.playShowTime = adsFile[FireConfigKey.playWaitKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.adsTimeKey] != null) {
        AdmobMaxTool.instance.sameInterval = adsFile[FireConfigKey.adsTimeKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.nativeTimeKey] != null) {
        AdmobMaxTool.instance.nativeTime = adsFile[FireConfigKey.nativeTimeKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.nativeClickKey] != null) {
        AdmobMaxTool.instance.nativeClick =
            adsFile[FireConfigKey.nativeClickKey].toInt();
      }
      if (adsFile[FireConfigKey.appStartTime] != null) {
        AdmobMaxTool.instance.startLoadTime =
            adsFile[FireConfigKey.appStartTime].toInt();
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsList = FireManager.adsFile[type.value];
        if (adsList is List) {
          adsList.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsList = FireManager.adsPlusFile[type.value];
        if (adsList is List) {
          adsList.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      adsFile[AdsSceneType.plus.value] = adsPlusFile[AdsSceneType.plus.value];
    }
    //   if ((remote.getString(FireConfigKey.userFileName)).isNotEmpty) {
    //     userFile = jsonDecode(remote.getString(FireConfigKey.userFileName));
    //     dynamic priceList = FireConfig.userFile[FireConfigKey.userName];
    //     if (priceList is List) {
    //       priceList.sort((a, b) {
    //         return (a[FireConfigKey.user_index]).compareTo(
    //           b[FireConfigKey.user_index],
    //         );
    //       });
    //     }
    //   }
    // }

    remote
        .setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 1),
            minimumFetchInterval: const Duration(hours: 24),
          ),
        )
        .then((value) async {
          //第一次拉取配置
          try {
            await remote.fetchAndActivate();
          } catch (error) {
            print(error);
          }
          updateRemoteSet();
        });
    //监听配置更新
    remote.onConfigUpdated.listen((event) async {
      await remote.activate();
      updateRemoteSet();
    });

    MobileAds.instance.initialize();

    AppLovinMAX.initialize(FireConfigKey.maxKey);

    final AppsFlyerOptions afiOS = AppsFlyerOptions(
      afDevKey: 'vJ6Sax2yK58yGZamTRTZZj',
      appId: '6751944433',
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
      manualStart: true,
    );

    late AppsflyerSdk _appsflyerSdk = AppsflyerSdk(afiOS);

    // Deep linking callback
    _appsflyerSdk.onDeepLinking((DeepLinkResult dp) async {
      switch (dp.status) {
        case Status.FOUND:
          print(dp.deepLink?.deepLinkValue);
          String? link = dp.deepLink?.deepLinkValue;
          isDeepLink = dp.deepLink?.isDeferred ?? false;
          if (link != null) {
            await getDeepDetails(link);
          }
          break;
        case Status.NOT_FOUND:
          print("deep link not found");
          break;
        case Status.ERROR:
          print("deep link error: ${dp.error}");
          break;
        case Status.PARSE_ERROR:
          print("deep link status parsing error");
          break;
      }
    });

    // Init of AppsFlyer SDK
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _appsflyerSdk.startSDK(
      onSuccess: () {
        print("onSuccess");
      },
      onError: (code, msg) {
        print("d error");
      },
    );
  }
}

Future<void> getDeepDetails(String info) async {
  Uri uri = Uri.parse(info);
  Map<String, String> para = uri.queryParameters;
  String? linkId = para['leadin'];
  if (linkId != null) {
    deepLink = linkId;
    appLinkId = linkId;
    await AppKey.save(AppKey.appLinkId, linkId);
  }
  String? plat = para['pqhre1kjd6'];
  if (plat == PlatformType.india.name) {
    apiPlatform = PlatformType.india;
  } else {
    apiPlatform = PlatformType.east;
  }
  bool isFirst = await AppKey.getBool('getDeepLink') ?? false;
  EventManager.instance.enventUpload(EventApi.deeplinkOpen, {
    'HLIage': isDeepLink ? 'aljUjha' : 'BkaYYva',
    'UKMkpe': isFirst,
  });
  pushDeepPageInfo?.call();
}

class DefaultOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      // case TargetPlatform.android:
      //   return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'sdfsaas',
    appId: '1:sdfasfasdf',
    projectId: 'xxabaasx',
    storageBucket: 'sdfasdfa.app',
    messagingSenderId: '1414151234',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3Ab_YYTOljO9x4T7vt5tOw0tYdIQxHPU',
    appId: '1:425765859418:ios:b360604df8e7db5b96e863',
    projectId: 'frame-ios-734dd',
    iosBundleId: 'com.frame.lumistream',
    storageBucket: 'frame-ios-734dd.firebasestorage.app',
    messagingSenderId: '425765859418',
  );
}

class AdsUnitId {
  static String admobOpenAdsUnitId = '';
  static String admobInterstitialAdsUnitId = '';
  static String admobRewardedAdsUnitId = '';
  static String admobNativeAdsUnitId = '';

  static String maxOpenAdsUnitId = '';
  static String maxInterstitialAdsUnitId = '';
  static String maxRewardedAdsUnitId = '';
}
