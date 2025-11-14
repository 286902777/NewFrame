import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../source/Common.dart';
import '../source/app_key.dart';

enum EventApi {
  homeExpose('bxww'),
  homeChannelExpose('pay42DsTpLo'),
  homeHistoryExpose('x123'),
  landpageExpose('ckDHswZx'),
  landpageFail('FlGFf1xsmC'),
  landpageUploadedExpose('ABwt123IuwR'),

  playStartAll('njVEu43WTD'),
  playSource('x4'),
  playSuc('x53s2'),
  playFail('mJ2S'),

  adReqPlacement('I1DAMk'),
  adReqSuc('k2yNHp42fbDKn'),
  adReqFail('VPieXM421kZtd'),
  adNeedShow('YziS23242hosBsS'),
  adShowPlacement('woC423npUzkuZ'),
  adShowFail('oolZb242JWNDM'),
  adClick('Ic24up'),
  historyExpose('R24YAAEZxgj'),

  deeplinkOpen('PS24po'),
  channellistExpose('IWiQeosdfsxCUv'),
  channellistClick('nyZiiswegbJdO'),
  channelpageExpose('slweN'),
  session('xsxb'),
  ads('xxsdc'),
  install('xssxzz1z');

  final String name;
  const EventApi(this.name);
}

class EventManager extends GetConnect {
  static const contentType = 'application/json';

  static final EventManager instance = EventManager()..onInit();

  List<Map<String, dynamic>> eventList = <Map<String, dynamic>>[];

  List<String> logArr = [];

  @override
  void onInit() async {
    httpClient.baseUrl = 'https://s.ewx.com/bs/wer';
    httpClient.maxAuthRetries = 1;
    httpClient.defaultContentType = EventManager.contentType;
  }

  Future<void> getLocalData() async {
    Map<String, dynamic>? data = await AppKey.getMap(AppKey.eventList);
    if (data != null) {
      for (var entry in data.entries) {
        eventList.add(entry.value);
        logArr.add(entry.key);
      }
    }
  }

  Future<Map<String, dynamic>> _addPara(bool isUserId) async {
    final storage = FlutterSecureStorage();
    String? uniqueId = await storage.read(key: 'unique_id');
    String uuId = '';
    // String androidId = await AndroidId().getId() ?? '';

    if (Platform.isIOS) {
      if (uniqueId != null) {
        uuId = uniqueId;
      } else {
        uuId = Uuid().v4();
        storage.write(key: 'unique_id', value: uuId);
      }
    }
    String modelInfo = '';
    String brandInfo = '';
    String systemVersion = '';
    String idfv = '';
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      modelInfo = iosInfo.model;
      brandInfo = iosInfo.systemName;
      systemVersion = iosInfo.systemVersion;
      idfv = iosInfo.identifierForVendor ?? '';
    } else {
      final AndroidDeviceInfo andInfo = await DeviceInfoPlugin().androidInfo;
      modelInfo = andInfo.manufacturer;
      brandInfo = andInfo.brand;
      systemVersion = andInfo.version.release;
    }
    Locale locale = window.locale;
    String? linkId;
    String? email;
    String? userId;
    //quick/cash，区分中东/印度平台
    PackageInfo info = await PackageInfo.fromPlatform();
    if (isUserId) {
      linkId = await AppKey.getString(AppKey.appLinkId);
      email = await AppKey.getString(AppKey.email);
      userId = await AppKey.getString(AppKey.appUserId);
    }

    Map<String, dynamic> commonPara = {};
    commonPara = {
      'applause': {
        'dab': locale.languageCode, //system_language
        'betony': 'mcc',
        'clever': info.version, //应用的版本
        'pompon': systemVersion, //操作系统版本号
        'forcible': Uuid().v4(), //log_id
        'bank': '', //android_id
      },
      'pelagic': {
        'pimp': '${DateTime.now().millisecondsSinceEpoch}', //日志发生的客户端时间
        'lithic': appBunldeId,
        'modish': modelInfo,
        'route': Uuid().v4(), //distinct_id
        'already': idfv, //idfv
        'methanol': brandInfo, //手机厂商，apple、 huawei、oppo
        'sexton':
            'tacoma', //映射关系：{“mac”: “android”, “tacoma”: “ios”, “moonlit”: “web”}
      },

      ///自定义后台字段
      'vftCKrlWGq/abdomen': linkId,
      'xCTaWZT/abdomen': apiPlatform == PlatformType.india
          ? 'YKozeiMhE'
          : 'JiAYLbh',
      'ChmtH/abdomen': email,
      'PGMBmtgPlq/abdomen': userId,
      'cJASu/abdomen': playFileId,
    };
    return commonPara;
  }

  Future<void> postRequest(
    EventApi api, {
    required Map<String, dynamic> para,
  }) async {
    if (Platform.isIOS) {
      bool has = eventList.any(
        (m) => m['applause']['forcible'] == para['applause']['forcible'],
      );
      if (has == false) {
        eventList.add(para);
        logArr.add(para['applause']['forcible']);
        Map<String, dynamic> saveData = {};
        eventList.forEach((m) {
          saveData[m['applause']['forcible']] = m;
        });
        await AppKey.save(AppKey.eventList, saveData);
        postApiEvent();
      } else {
        print('-------${para['applause']['forcible']}');
        postApiEvent();
      }
      // } else {
      //   bool has = eventList.any(
      //     (m) => m['dramatic']['knurl'] == para['dramatic']['knurl'],
      //   );
      //   if (has == false) {
      //     eventList.add(para);
      //     logArr.add(para['dramatic']['knurl']);
      //     Map<String, dynamic> saveData = {};
      //     eventList.forEach((m) {
      //       saveData[m['dramatic']['knurl']] = m;
      //     });
      //     await AppKey.save(AppKey.eventList, saveData);
      //     uploadTbaEvent();
      //   } else {
      //     print('-------${para['dramatic']['knurl']}');
      //     uploadTbaEvent();
      //   }
    }
  }

  void postApiEvent() async {
    if (EventManager.instance.eventList.isNotEmpty) {
      Locale locale = window.locale;
      try {
        Map<String, dynamic> para = EventManager.instance.eventList.first;
        if (Platform.isIOS) {
          Response response = await EventManager.instance.post(
            '',
            contentType: "application/json",
            para,
            headers: {'sexton': 'tacoma'},
            query: {
              'pimp': '${DateTime.now().millisecondsSinceEpoch}',
              'dab': locale.languageCode, //日志发生的客户端时间
            },
          );
          if (response.statusCode == 200) {
            EventManager.instance.eventList.removeWhere(
              (m) => m['applause']['forcible'] == para['applause']['forcible'],
            );
            Map<String, dynamic> saveData = {};
            EventManager.instance.eventList.forEach((m) {
              saveData[m['applause']['forcible']] = m;
            });
            if (para['paterson'] == 'calico') {
              AppKey.save(AppKey.appInstall, true);
            }
            if (para['paterson'] == 'ckDHZx') {
              AppKey.save(AppKey.isFirstLink, true);
            }
            await AppKey.save(AppKey.eventList, saveData);
          } else if (response.statusCode != null) {
            print("object");
          }
          // } else {
          // String androidId = await AndroidId().getId() ?? '';
          // Locale locale = window.locale;
          //
          // Response response = await EventManager.instance.post(
          //   '',
          //   para,
          //   headers: {'feverish': locale.languageCode},
          //   query: {'nne': androidId, 'ivy': Bunlde_Id, 'copter': 'mcc'},
          // );
          // if (response.statusCode == 200) {
          //   EventManager.instance.eventList.removeWhere(
          //     (m) => m['dramatic']['knurl'] == para['dramatic']['knurl'],
          //   );
          //   Map<String, dynamic> saveData = {};
          //   EventManager.instance.eventList.forEach((m) {
          //     saveData[m['dramatic']['knurl']] = m;
          //   });
          //   await AppKey.save(AppKey.eventList, saveData);
          //   if (para['seventy'] == 'tarpaper') {
          //     AppKey.save(AppKey.appInstall, true);
          //   }
          //   if (para['seventy'] == 'lgSRdlEYS') {
          //     AppKey.save(AppKey.isFirstLink, true);
          //   }
          //   if (para['seventy'] == 'fbEKYbC') {
          //     AppKey.save('getDeepLink', true);
          //   }
          // } else {
          //   print("object");
          // }
        }
        postApiEvent();
      } catch (e) {
        print("${e.hashCode}");
      }
    }
  }

  // install
  Future<void> install(bool isUserId) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    Map<String, dynamic> dict = {
      'paterson': 'calico',
      // 'periodic': 'build/${info.buildNumber}', //系统构建版本，Build.ID， 以 build/ 开头
      // 'eta': '',
      // 'salutary': 'consul', //映射关系：{“executor”: 0, “consul”: 1}
      // 'diogenes': 0,
      // 'confound': 0,
      // 'steppe': 0,
      // 'anywhere': 0,
      // 'chess': 0,
      // 'eurydice': 0,
    };

    // if (Platform.isIOS) {
    //   dict = {
    //     EventApi.install.name: {
    //       'hudson': 'build/${info.buildNumber}', //系统构建版本，Build.ID， 以 build/ 开头
    //       'except': '',
    //       'grudge': 1,
    //       'stalwart': 0,
    //       'chancy': 0,
    //       'robot': 0,
    //       'manumit': 0,
    //       'lutz': 0,
    //       'cetera': 0,
    //     },
    //   };
    // } else {
    //   dict = {'seventy': 'tarpaper'};
    // }
    Map<String, dynamic> commonPara = await _addPara(isUserId);
    await postRequest(EventApi.install, para: commonPara..addAll(dict));
  }

  Future<void> session() async {
    // Map<String, dynamic> dict =
    //     Platform.isIOS ? {'flautist': 'blest'} : {'seventy': 'cranny'};
    Map<String, dynamic> dict = {'bradbury': {}};
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(EventApi.session, para: commonPara..addAll(dict));
  }

  Future<void> uploadAds(Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(EventApi.ads, para: commonPara..addAll(para ?? {}));
  }

  Future<void> enventUpload(EventApi event, Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    if (para == null) {
      await postRequest(
        event,
        para: {'paterson': event.name}..addAll(commonPara),
      );
    } else {
      Map<String, dynamic> dict = {
        for (var entry in para.entries) 'outlawry<${entry.key}': entry.value,
      };
      await postRequest(
        event,
        para: {'paterson': event.name}
          ..addAll(commonPara)
          ..addAll(dict),
      );
    }
  }
}
