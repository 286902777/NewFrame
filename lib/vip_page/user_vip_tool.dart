import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frame/source/app_key.dart';
import 'package:frame/source/fire_manager.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../event/event_manager.dart';
import '../model/vip_data.dart';
import '../source/Common.dart';

enum UserVipIdKey {
  weak('rme_weekly'),
  year('rme_yearly'),
  life('rme_lifetime');

  final String value;
  const UserVipIdKey(this.value);
}

class UserVipTool with ChangeNotifier {
  static final UserVipTool instance = UserVipTool._internal();
  UserVipIdKey idKey = UserVipIdKey.weak;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  final ValueNotifier<VipData> vipData = ValueNotifier(VipData());
  final ValueNotifier<List<VipProductData>> productResultList = ValueNotifier(
    [],
  );

  List<ProductDetails> _productList = [];
  List<PurchaseDetails> _purchaseList = [];

  bool isStore = false;
  factory UserVipTool() {
    return instance;
  }

  UserVipTool._internal() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        EasyLoading.dismiss();
        _subscription.cancel();
      },
      onError: (error) {
        EasyLoading.dismiss();
        print(error.hashCode);
      },
    );

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          InAppPurchase.instance
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(VipPaymentQueueDelegate());
    } else {
      getAndroidProductInfo().ignore();
    }
  }

  Future<List<ProductDetails>> getAndroidProductInfo() async {
    try {
      if (!(await InAppPurchase.instance.isAvailable())) {
        return [];
      }
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails({
            UserVipIdKey.weak.value,
            UserVipIdKey.year.value,
            UserVipIdKey.life.value,
          });
      if (response.notFoundIDs.isNotEmpty) {
        return [];
      }
      _productList = response.productDetails;
      if (_productList.isNotEmpty) {
        _productList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        List<VipProductData> newProductList = [];

        for (Map<String, dynamic> file
            in FireManager.userVipFile[FireConfigKey.userVipInfoName]) {
          for (ProductDetails m in _productList) {
            String productId = file[FireConfigKey.userVipProductId];
            if (productId == m.id) {
              VipProductData model = VipProductData(
                productId: m.id,
                title: file[FireConfigKey.userVipType],
                productInfo: '',
                price: m.rawPrice,
                showPrice: m.price,
                currency: m.currencySymbol,
                isSelect: file[FireConfigKey.userVipSelect],
                hot: file[FireConfigKey.userVipHot],
              );
              newProductList.add(model);
            }
          }
        }
        productResultList.value = newProductList;
      }
      return _productList;
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription.cancel();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    EasyLoading.dismiss();
    _purchaseList = purchaseDetailsList;

    purchaseDetailsList.sort(
      (a, b) => (int.tryParse(b.transactionDate ?? '') ?? 0).compareTo(
        int.tryParse(a.transactionDate ?? '') ?? 0,
      ),
    );
    if (purchaseDetailsList.isNotEmpty) {
      PurchaseDetails purchaseDetails = purchaseDetailsList.first;
      if (purchaseDetails.status != PurchaseStatus.pending) {
        VipProductData? productInfo;
        if (productResultList.value.isNotEmpty &&
            purchaseDetails.productID.isNotEmpty) {
          productInfo = productResultList.value.firstWhere(
            (element) => element.productId == purchaseDetails.productID,
          );
        }
        VipData model = VipData(
          purchaseDetails: purchaseDetails,
          name: productInfo?.title,
        );
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //如果苹果返回成功之后去验证票据
          if (Platform.isIOS) {
            model = await _verifyPurchase(purchaseDetails);
            // } else {
            //   model = await _verifyAndroidPurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          //被取消，重置vip信息
          model = vipData.value;
          model.purchaseDetails = purchaseDetails;
          print('premium_fail');
          EventManager.instance.eventUpload(EventApi.premiumFail, {
            EventParaName.value.name: vipProduct.value,
          });
        }
        if (purchaseDetails.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
        //通知监听者
        _noticePurchaseStatusListener(model);
        await clearFailedPurchases();
      }
    } else {
      _noticePurchaseStatusListener(VipData());
    }
  }

  Future<void> queryProductInfo() async {
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (isAvailable == false) {
      return;
    }
    List<String> productIds = [];
    if (FireManager.userVipFile.isNotEmpty) {
      for (Map<String, dynamic> m
          in FireManager.userVipFile[FireConfigKey.userVipInfoName]) {
        productIds.add(m[FireConfigKey.userVipProductId]);
      }
    } else {
      productIds = [
        UserVipIdKey.weak.value,
        UserVipIdKey.year.value,
        UserVipIdKey.life.value,
      ];
    }
    final ProductDetailsResponse productDetailResponse = await InAppPurchase
        .instance
        .queryProductDetails(productIds.toSet());
    _productList = productDetailResponse.productDetails;

    if (_productList.isNotEmpty) {
      _productList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      List<VipProductData> newProductList = [];

      for (Map<String, dynamic> file
          in FireManager.userVipFile[FireConfigKey.userVipInfoName]) {
        for (ProductDetails m in _productList) {
          if (file[FireConfigKey.userVipProductId] == m.id) {
            VipProductData model = VipProductData(
              productId: m.id,
              title: file[FireConfigKey.userVipType],
              productInfo: '',
              price: m.rawPrice,
              showPrice: m.price,
              currency: m.currencySymbol,
              isSelect: file[FireConfigKey.userVipSelect],
              hot: file[FireConfigKey.userVipHot],
            );
            newProductList.add(model);
          }
        }
      }
      productResultList.value = newProductList;
    }
  }

  ///走自己后端验证票据
  Future<VipData> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    VipProductData? productInfo;
    SKRequestMaker().startRefreshReceiptRequest();
    String receipt = await SKReceiptManager.retrieveReceiptData();

    if (receipt.isEmpty) {
      receipt = purchaseDetails.verificationData.serverVerificationData;
    }
    if (productResultList.value.isNotEmpty) {
      productInfo = productResultList.value.firstWhere(
        (element) => element.productId == purchaseDetails.productID,
      );
    }

    String url =
        'https://rme.frameplayvid.com/horsecar/skwmvb8osg/rantism'; // https://rme.frameplayvid.com/v1/ios/receipt-verifier
    final storage = FlutterSecureStorage();
    String? uniqueId = await storage.read(key: 'unique_id');
    String uuId = '';
    if (uniqueId != null) {
      uuId = uniqueId;
    } else {
      uuId = Uuid().v4();
      storage.write(key: 'unique_id', value: uuId);
    }
    Map params = {};
    // params['device_id'] = uuId;
    // params['package_name'] = (await PackageInfo.fromPlatform()).packageName;
    // params['product_id'] = purchaseDetails.productID;
    // params['receipt_base64_data'] =
    //     purchaseDetails.verificationData.serverVerificationData;
    params['catalin'] = uuId;
    params['hamates'] = (await PackageInfo.fromPlatform()).packageName;
    params['indivinity'] = purchaseDetails.productID;
    params['polyptych'] = receipt;
    Response response = await GetConnect().post(
      url,
      params,
      contentType: 'application/json',
      headers: {'humbly': 'unitooth', 'Host': 'rme.frameplayvid.com'},
    );
    dynamic responseBody = response.body;

    if (responseBody is Map) {
      dynamic entity = responseBody['moles']; //entity
      if (entity is Map<String, dynamic>) {
        VipData model = VipData.fromJson(entity);
        model.success = true;
        model.purchaseDetails = purchaseDetails;
        model.name = productInfo?.title;
        model.productId = purchaseDetails.productID;

        if (Platform.isIOS) {
          List pendingRenewalInfo =
              entity['gmsko6t1ir'] ?? []; //pending_renewal_info
          if (pendingRenewalInfo.isNotEmpty) {
            model.autoRenew =
                (pendingRenewalInfo[0]['peavie']) == '1'; //auto_renew_status
          }

          List latestReceiptInfo =
              entity['adversed'] ?? []; //latest_receipt_info
          if (latestReceiptInfo.isNotEmpty) {
            model.expiresDate = latestReceiptInfo[0]['bilby']; //expires_date_ms
          }
        }
        await AppKey.save(AppKey.isVipUser, model.ok);
        await AppKey.save(AppKey.vipProductId, model.productId);
        if (model.ok == true &&
            purchaseDetails.status == PurchaseStatus.purchased &&
            isStore == false) {
          print('premium_suc');
          String userId = await AppKey.getString(AppKey.appUserId) ?? '';
          EventManager.instance.eventUpload(EventApi.premiumSuc, {
            EventParaName.value.name: vipProduct.value,
            EventParaName.type.name: vipType.value, //type
            EventParaName.method.name: vipMethod.value, //method
            EventParaName.source.name: vipSource.value, //source
            EventParaName.iPlayerUid.name: userId,
          });
        }
        vipDoneBlock?.call(model, isStore == false);
        return model;
      }
    }
    await AppKey.save(AppKey.isVipUser, false);
    vipDoneBlock?.call(
      VipData(purchaseDetails: purchaseDetails),
      isStore == false,
    );
    return VipData(purchaseDetails: purchaseDetails);
  }

  // ///走自己后端验证票据
  // Future<VipModel> _verifyAndroidPurchase(
  //     PurchaseDetails purchaseDetails,
  //     ) async {
  //   ProductModel? productInfo;
  //   if (productResultList.value.isNotEmpty) {
  //     productInfo = productResultList.value.firstWhere(
  //           (element) => element.productId == purchaseDetails.productID,
  //     );
  //   }
  //
  //   String url = 'https://amo.streamoraapp.com/glucate/coreid/catarrh';
  //   var androidId = await AndroidId().getId();
  //   var packageInfo = await PackageInfo.fromPlatform();
  //   Map params = {};
  //   // params  {
  //   //     "device_id": "A14E05AB-01DB-4889-B000-67D92AA88660",
  //   //   "purchased": true / false,
  //   //   "package_name": "com.cgfloat.movtube",
  //   //   "product_id": "monthly_movie_cgfloat",
  //   //   "quantity": 1,
  //   //   "purchase_time": 1423197856877,
  //   //   "purchase_state": 0,
  //   //   "purchase_token": "dccfjnioeeojanngnfspekea.AO-J1OzsBdFJhqhLtvtybnQbBMxELYL4M-wClITbJFd-rpnPzYWCOlHyK69xgXBYN8lx99XfMBhD8JPg6u3SsgNvPt2hhbvogszRxjtA15rP-qWBYv_Rytw"
  //   //   }
  //   params['cudbears'] = androidId;
  //   params['defluxion'] = packageInfo.packageName;
  //   params['kelek'] = purchaseDetails.productID;
  //   params['jarosite'] = purchaseDetails.transactionDate;
  //   params['unabusable'] =
  //       purchaseDetails.verificationData.serverVerificationData;
  //   params['sunning'] = 1;
  //   Response response = await GetConnect().post(
  //     url,
  //     params,
  //     contentType: 'application/json',
  //     headers: {'deputator': 'hostessed', 'Host': 'amo.streamoraapp.com'},
  //   );
  //   dynamic responseBody = response.body;
  //   if (responseBody is Map) {
  //     dynamic entity = responseBody['duplone']; //entity
  //     if (entity is Map<String, dynamic>) {
  //       VipModel model = VipModel.fromJson(entity);
  //       model.success = true;
  //       model.purchaseDetails = purchaseDetails;
  //       model.name = productInfo?.title;
  //       model.productId = purchaseDetails.productID;
  //       model.expiresDate = entity['kyle']; //expires_date_ms
  //       model.ok = entity['ukyblawwhc'];
  //
  //       String? userId = await UserInfo.getString(UserInfo.appUserId);
  //       await UserInfo.save(UserInfo.isVipUser, model.ok);
  //       await UserInfo.save(UserInfo.vipProductId, model.productId);
  //       if (model.ok == true &&
  //           purchaseDetails.status == PurchaseStatus.purchased &&
  //           isStore == false) {
  //         print('premium_suc');
  //         EventManager.instance.enventUpload(EventApi.premium_suc, {
  // 'KsAj': subscriberProduct.value,
  // 'IOz': subscriberType.value, //type
  // 'XfJe': subscriberMethod.value, //method
  // 'GSjzKapRnA': subscriberSource.value, //source
  // 'PGMBmtgPlq': userId,
  //         });
  //       }
  //       payDoneJump?.call(model, isStore == false);
  //       return model;
  //     }
  //   }
  //   await UserInfo.save(UserInfo.isVipUser, false);
  //   payDoneJump?.call(
  //     VipModel(purchaseDetails: purchaseDetails),
  //     isStore == false,
  //   );
  //   return VipModel(purchaseDetails: purchaseDetails);
  // }

  Future<VipData> toGetPay(VipProductData? selectModel) async {
    Completer<VipData> completer = Completer();

    isStore = false;

    ///完结以前的订单
    await clearFailedPurchases();

    String? sProductId = '';
    if (selectModel != null) {
      sProductId = selectModel.productId;
    } else {
      sProductId = productResultList.value
          .firstWhere((m) => m.isSelect == true)
          .productId;
    }
    if (Platform.isIOS) {
      // 周：weekly_kreel：2.99
      // 年：annual_kreel：19.99
      // 终身：lifetime_kreel：29.99
      switch (sProductId) {
        case 'rme_weekly':
          vipProduct = VipProduct.weekly;
        case 'rme_yearly':
          vipProduct = VipProduct.yearly;
        case 'rme_lifetime':
          vipProduct = VipProduct.lifetime;
        default:
          break;
      }
    }

    String? userId = await AppKey.getString(AppKey.appUserId);
    EventManager.instance.eventUpload(EventApi.premiumClick, {
      EventParaName.value.name: vipProduct.value,
      EventParaName.type.name: vipType.value, //type
      EventParaName.method.name: vipMethod.value, //method
      EventParaName.source.name: vipSource.value, //source
      EventParaName.iPlayerUid.name: userId,
    });

    ProductDetails currentProductDetails = _productList.firstWhere(
      (element) => element.id == sProductId,
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: currentProductDetails,
    );

    //开始购买
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      EasyLoading.dismiss();
      if (completer.isCompleted == false) {
        completer.complete(VipData());
      }
    }

    return completer.future;
  }

  ///恢复之前的购买
  Future restore({bool? appStart = false, bool? isClick = false}) async {
    isStore = true;
    if (appStart == false) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    VipProductData? productInfo;
    SKRequestMaker().startRefreshReceiptRequest();
    String receipt = await SKReceiptManager.retrieveReceiptData();
    String productId = await AppKey.getString(AppKey.vipProductId) ?? '';
    if (productResultList.value.isNotEmpty) {
      productInfo = productResultList.value.firstWhere(
        (element) => element.productId == productId,
      );
    }

    String url = 'https://rme.frameplayvid.com/horsecar/skwmvb8osg/rantism';
    final storage = FlutterSecureStorage();
    String? uniqueId = await storage.read(key: 'unique_id');
    String uuId = '';
    if (uniqueId != null) {
      uuId = uniqueId;
    } else {
      uuId = Uuid().v4();
      storage.write(key: 'unique_id', value: uuId);
    }
    Map params = {};
    params['catalin'] = uuId;
    params['hamates'] = (await PackageInfo.fromPlatform()).packageName;
    params['indivinity'] = productId;
    params['polyptych'] = receipt;
    Response response = await GetConnect().post(
      url,
      params,
      contentType: 'application/json',
      headers: {'humbly': 'unitooth', 'Host': 'rme.frameplayvid.com'},
    );
    dynamic responseBody = response.body;

    if (responseBody is Map) {
      dynamic entity = responseBody['moles']; //entity
      if (entity is Map<String, dynamic>) {
        VipData model = VipData.fromJson(entity);
        model.success = true;
        model.name = productInfo?.title;
        model.productId = productId;

        if (Platform.isIOS) {
          List pendingRenewalInfo =
              entity['gmsko6t1ir'] ?? []; //pending_renewal_info
          if (pendingRenewalInfo.isNotEmpty) {
            model.autoRenew =
                (pendingRenewalInfo[0]['peavie']) == '1'; //auto_renew_status
          }

          List latestReceiptInfo =
              entity['adversed'] ?? []; //latest_receipt_info
          if (latestReceiptInfo.isNotEmpty) {
            model.expiresDate = latestReceiptInfo[0]['bilby']; //expires_date_ms
          }
        }
        await AppKey.save(AppKey.isVipUser, model.ok);
        await AppKey.save(AppKey.vipProductId, model.productId);
        if (model.ok == true) {
          print('premium_suc');
          String userId = await AppKey.getString(AppKey.appUserId) ?? '';
          EventManager.instance.eventUpload(EventApi.premiumSuc, {
            EventParaName.value.name: vipProduct.value,
            EventParaName.type.name: vipType.value, //type
            EventParaName.method.name: vipMethod.value, //method
            EventParaName.source.name: vipSource.value, //source
            EventParaName.iPlayerUid.name: userId,
          });
        }
        vipDoneBlock?.call(model, isStore == false);
        return model;
      }
    }
    await AppKey.save(AppKey.isVipUser, false);
    vipDoneBlock?.call(VipData(), isStore == false);
  }

  Future<void> clearFailedPurchases() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final wrapper = SKPaymentQueueWrapper();
      final transactions = await wrapper.transactions();
      for (final transaction in transactions) {
        await wrapper.finishTransaction(transaction);
      }
    }
    //完成订单状态
    for (var element in _purchaseList) {
      if (element.status != PurchaseStatus.pending) {
        if (element.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(element);
        }
      }
    }
  }

  ///订单状态监听-----------------------------------------

  void _noticePurchaseStatusListener(VipData data) {
    EasyLoading.dismiss();
    if (data.purchaseDetails != null || data.ok == false) {
      UserVipTool.instance.vipData.value = data;
      UserVipTool.instance.vipData.notifyListeners();
    }
  }
}

class VipPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
