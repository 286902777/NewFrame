import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frame/source/CusToast.dart';
import 'package:get/get.dart';

import '../source/Common.dart';

enum HttpState { success, fail, start, end }

enum ApiKey {
  home(
    'coercive',
    '/v1/choluria/bethumped/manlikely',
  ), // /v1/app/open/data  current_page:nitering page_size: prereport
  folder(
    'alkaligen',
    '/v1/unwild/cuffless/kxxg1ke4qr',
  ), // /v1/app/open/file/{uid}/{dirId} current_page:meature page_size: shopmaid
  video(
    'metabole',
    '/v1/fonly/bawneen/logt5dmbxl',
  ), // 视频资源/v1/app/download/file/{uid}/{fileId}
  userPools(
    'xeromorphy',
    '/v1/banked/hebraical',
  ), //拉取运营推荐数据 HTTP POST /v1/app/push_operation_pools

  playRecommend(
    'thrimp',
    '/v1/irk4ddparn/hb50idujge',
  ), //app端推荐接口 HTTP POST /v1/app/recommend

  report(
    'despotist',
    '/v1/karbi/7tkkb35xeu',
  ), //app违规举报事件  HTTP POST /v1/app/violate_report
  event('hoselike', '/v1/cotoin/obtain'); //app端事件上报 HTTP POST  v1/app/events

  final String headName;
  final String address;
  const ApiKey(this.headName, this.address);
}

typedef HttpStateListener =
    void Function(
      String url,
      HttpState state, {
      Map<String, dynamic>? para,
      dynamic result,
      int? code,
      String? msg,
    });

typedef CompleteHandle = void Function();

typedef SuccessHandle = void Function(dynamic info);
typedef FailHandle = void Function(bool refresh, int code, String msg);

class HttpManager extends GetConnect {
  static final HttpManager instance = HttpManager();
  static const contentType = 'application/json';
  static const textPlain = 'text/plain';

  List<String> east = [
    'https://api.framedoodlo.com',
    'https://api.frameenq.com',
  ];
  List<String> india = [
    'https://api.framerelocate.com',
    'https://api.framecreame.com',
  ];

  String hostUrl = '';

  void setHost(PlatformType? source) {
    hostUrl = source == PlatformType.india
        ? 'https://api.framerelocate.com'
        : 'https://api.framedoodlo.com';
    httpClient.baseUrl = hostUrl;
    httpClient.maxAuthRetries = 3;
    httpClient.defaultContentType = HttpManager.contentType;
  }

  static getRequest(
    ApiKey api,
    PlatformType source,
    String? url,
    bool show, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && show == true) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    HttpManager.instance.setHost(source);
    HttpManager.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.get(
        '${api.address}$url',
        query: newPara,
        headers: {
          'u1gp9mp9ay': api.headName,
          'Content-Type': HttpManager.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      EasyLoading.showToast(error.toString());
    }

    if (completeHandle != null) {
      completeHandle();
      HttpManager.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
      EasyLoading.dismiss();
    }
  }

  static postRequest(
    ApiKey api,
    PlatformType source, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && api != ApiKey.userPools) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    HttpManager.instance.setHost(source);
    HttpManager.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        api.address,
        newPara,
        headers: {
          'u1gp9mp9ay': api.headName,
          'Content-Type': HttpManager.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      CusToast.show(message: error.toString(), type: CusToastType.fail);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpManager.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
    }
  }

  static recommendPostRequest(
    ApiKey api,
    PlatformType source,
    bool show, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && show) {
      EasyLoading.show(status: 'loading...');
    }
    HttpManager.instance.setHost(source);
    HttpManager.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        api.address,
        newPara,
        headers: {
          'u1gp9mp9ay': api.headName,
          'Content-Type': HttpManager.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      CusToast.show(message: error.toString(), type: CusToastType.fail);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpManager.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
    }
  }

  static eventPostRequest(
    PlatformType source, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    HttpManager.instance.setHost(source);
    HttpManager.instance.noticeHttpListeners(
      ApiKey.event.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        ApiKey.event.address,
        {
          'returfer': HttpManager.instance.sshToKey(jsonEncode([newPara])),
        },
        headers: {
          'u1gp9mp9ay': ApiKey.event.headName,
          'Content-Type': HttpManager.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        ApiKey.event,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, ApiKey.event, para: para, failHandle: failHandle);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpManager.instance.noticeHttpListeners(
        ApiKey.event.address,
        HttpState.end,
        para: para,
      );
    }
  }

  bool fixApiURLAddress(PlatformType? source) {
    if (apiPlatform == PlatformType.india) {
      if (hostUrl == east.last) {
        return false;
      } else {
        hostUrl = india.last;
      }
    } else {
      if (hostUrl == east.last) {
        return false;
      } else {
        hostUrl = east.last;
      }
    }
    httpClient.baseUrl = hostUrl;
    return false;
  }

  static _handleResult(
    int? code,
    dynamic result,
    ApiKey key, {
    Map<String, dynamic>? para,
    PlatformType? source,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
  }) async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (result != null && code == 200) {
      if (result is String) {
        if (successHandle != null) {
          successHandle(result);
        }
      } else if (result is Map) {
        if (result.keys.isNotEmpty) {
          if (successHandle != null) {
            successHandle(result);
          }
          HttpManager.instance.noticeHttpListeners(
            key.address,
            HttpState.success,
            para: para,
            result: result,
          );
        } else {
          String retMsg = result['msg'] ?? result['detail'] ?? 'No Data';
          if (failHandle != null) {
            bool newApi = HttpManager.instance.fixApiURLAddress(source);
            failHandle(newApi, code ?? -1000, retMsg);
          }
          HttpManager.instance.noticeHttpListeners(
            key.address,
            HttpState.fail,
            code: code,
            msg: retMsg,
          );
        }
      } else if (result is bool) {
        if (successHandle != null) {
          successHandle(result);
        }
      } else if (result is List) {
        if (result.isNotEmpty) {
          if (successHandle != null) {
            successHandle(result);
          }
          HttpManager.instance.noticeHttpListeners(
            key.address,
            HttpState.success,
            para: para,
            result: result,
          );
        } else {
          HttpManager.instance.noticeHttpListeners(
            key.address,
            HttpState.fail,
            code: code,
            msg: '',
          );
        }
      }
    } else {
      String retMsg = 'request failed!';
      if (result != null) {
        retMsg = result['msg'] ?? result['detail'] ?? 'request failed!';
      }
      if (failHandle != null) {
        bool newApi = HttpManager.instance.fixApiURLAddress(source);
        failHandle(newApi, code ?? 404, retMsg);
      }
      HttpManager.instance.noticeHttpListeners(
        key.address,
        HttpState.fail,
        code: code,
        msg: retMsg,
      );
    }
  }

  static _handleError(
    dynamic error,
    ApiKey key, {
    Map<String, dynamic>? para,
    PlatformType? source,
    FailHandle? failHandle,
  }) {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    bool newApi = HttpManager.instance.fixApiURLAddress(source);
    int code = -1000;
    if (failHandle != null) {
      failHandle(newApi, code, error.toString());
    }
    HttpManager.instance.noticeHttpListeners(
      key.address,
      HttpState.fail,
      code: code,
      msg: error.toString(),
    );
  }

  static final Map<String, HttpStateListener> _listenersMap = {};

  static addListener(String key, HttpStateListener listener) {
    _listenersMap[key] = listener;
  }

  static removeListener(String key) {
    _listenersMap.remove(key);
  }

  static removeAllListener() {
    _listenersMap.clear();
    // ValueNotifier
  }

  void noticeHttpListeners(
    String url,
    HttpState httpState, {
    Map<String, dynamic>? para,
    dynamic result,
    int? code,
    String? msg,
  }) {
    _listenersMap.forEach((key, value) {
      value(
        url,
        httpState,
        para: {}..addAll(para ?? {}),
        result: result,
        code: code,
        msg: msg,
      );
    });
  }

  String writeSSH(String videoAddress) {
    String base64Str = '8bwhcjlL8ba9I0wCvSvjWAz6A==';
    final key = Key.fromBase64(base64Str.substring(3));
    // final key = Key.fromBase64('2QRaKUXg8Y/RqBPJJiAyVA==');
    final encry = Encrypter(AES(key, mode: AESMode.ecb));
    return encry.decrypt64(videoAddress);
  }

  String sshToKey(String data) {
    String tokenStr = 'bxs1lcNodheqTX1HbwVHWJyFGy0Gnt3qKUBgGD';
    // String tokenStr = 'gi29bkCXpPZnxCut7LohE6J1r5tHL75CwBMQU';

    String offStr = 'lx2Xk4dLo38c9Z2Q2a';
    final key = Key.fromUtf8(tokenStr.substring(6));
    final offIv = IV.fromUtf8(offStr.substring(2));

    final encry = Encrypter(AES(key, mode: AESMode.cbc));
    final result = encry.encrypt(data, iv: offIv);
    return result.base64;
  }
}
