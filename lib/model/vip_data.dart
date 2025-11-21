import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';

VipData vipDataFromJson(Map<String, dynamic> s) => VipData.fromJson(s);

String vipDataToJson(VipData data) => json.encode(data.toJson());

enum VipStatus { none, vip }

class VipData {
  String? name;
  String? info;
  String? productId;
  bool? success = false;
  bool? ok = false;
  bool? autoRenew = false;
  int? expiresDate = 0;
  PurchaseDetails? purchaseDetails;

  VipData({
    this.name,
    this.info,
    this.productId,
    this.success,
    this.ok,
    this.autoRenew,
    this.expiresDate,
    this.purchaseDetails,
  });

  factory VipData.fromJson(Map<String, dynamic> json) => VipData(
    name: json["name"] ?? '',
    info: json["info"] ?? '',
    productId: json["productId"] ?? '',
    success: json["success"] ?? false,
    ok: json["glancer"] ?? false,
    autoRenew: json["autoRenew"] ?? false,
    expiresDate: json["expiresDate"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "info": info,
    "productId": productId,
    "success": success,
    "ok": ok,
    "autoRenew": autoRenew,
    "expiresDate": expiresDate,
  };

  get status {
    if (ok ?? false == true) {
      return VipStatus.vip;
    }
    return VipStatus.none;
  }
}

class VipProductData {
  VipProductData({
    required this.productId,
    required this.title,
    required this.productInfo,
    required this.price,
    required this.showPrice,
    required this.currency,
    required this.isSelect,
    required this.hot,
  });
  String productId;
  String title;
  String productInfo;
  double price;
  String showPrice;
  String currency;
  bool isSelect;
  bool hot;
}
