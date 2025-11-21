import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frame/source/fire_manager.dart';
import 'package:frame/source/web_page.dart';
import 'package:frame/vip_page/user_vip_base_page.dart';
import 'package:frame/vip_page/user_vip_tool.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import '../event/event_manager.dart';
import '../generated/assets.dart';
import '../model/vip_data.dart';
import '../source/Common.dart';
import 'alert_user_vip_fail_page.dart';

class UserVipPage extends StatefulWidget {
  const UserVipPage({super.key});

  @override
  State<UserVipPage> createState() => _UserVipPageState();
}

class _UserVipPageState extends State<UserVipPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  VipProductData? selectData;

  @override
  void initState() {
    super.initState();
    _loadData();
    vipType = VipType.page;
    EventManager.instance.eventUpload(EventApi.premiumExpose, {
      EventParaName.type.name: vipType.value, //type
      EventParaName.method.name: vipMethod.value, //method
      EventParaName.source.name: vipSource.value, //source
    });
    vipDoneBlock = (mod, pay) {
      if (mod.purchaseDetails?.status != PurchaseStatus.canceled &&
          pay == true) {
        if (mod.ok == false) {
          showDialog(
            context: context,
            builder: (context) => AlertUserVipFailPage(),
          );
        }
      }
    };
  }

  void _loadData() async {
    if (UserVipTool.instance.productResultList.value.isEmpty) {
      EasyLoading.show(status: 'loading...');
      await UserVipTool.instance.queryProductInfo();
      EasyLoading.dismiss();
    }
    // List<VipProductData> lists = [];
    // VipProductData s = VipProductData(
    //   productId: 'sd',
    //   title: 'lift',
    //   productInfo: 'productInfo',
    //   price: 29.99,
    //   showPrice: '${'\$'}29.99',
    //   currency: '*',
    //   isSelect: true,
    //   hot: true,
    // );
    // VipProductData sx = VipProductData(
    //   productId: 'ssd',
    //   title: 'year',
    //   productInfo: 'productInfo',
    //   price: 19.99,
    //   showPrice: '${'\$'}19.99',
    //   currency: '*',
    //   isSelect: false,
    //   hot: false,
    // );
    // VipProductData ssx = VipProductData(
    //   productId: 'ssd',
    //   title: 'weak',
    //   productInfo: 'productInfo',
    //   price: 2.99,
    //   showPrice: '${'\$'}2.99',
    //   currency: '*',
    //   isSelect: false,
    //   hot: false,
    // );
    // lists.add(s);
    // lists.add(sx);
    // lists.add(ssx);
    //
    // UserVipTool.instance.productResultList.value = lists;
    dynamic fileList = FireManager.userVipFile[FireConfigKey.userVipInfoName];
    if (fileList is List) {
      for (VipProductData m in UserVipTool.instance.productResultList.value) {
        for (Map<String, dynamic> dic in fileList) {
          if (m.productId == dic[FireConfigKey.userVipProductId]) {
            m.isSelect = dic[FireConfigKey.userVipSelect];
            if (m.isSelect == true) {
              selectData = m;
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UserVipBasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: navbar(),
        body: Stack(
          children: [
            Positioned(
              top:
                  Get.width / 375 * 240 -
                  50 -
                  (Platform.isIOS ? 44 : 56) -
                  MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              bottom: 0,
              child: ValueListenableBuilder(
                valueListenable: UserVipTool.instance.vipData,
                builder: (BuildContext context, VipData vip, Widget? child) {
                  return Column(
                    children: [
                      Expanded(child: _contentWidget(vip)),
                      vip.status == VipStatus.none
                          ? _normalBottomV(vip)
                          : _userBottomV(vip),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 22,
              left: 16,
              child: Image.asset(Assets.svipSvipPro, width: 148, height: 68),
            ),
          ],
        ),
      ),
    );
  }

  AppBar navbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(width: 8),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.assetsBack, width: 24),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            UserVipTool.instance.restore(isClick: true);
          },
          child: Container(
            alignment: Alignment.center,
            width: 48,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(11)),
              color: Color(0xFFB2CEFA),
            ),
            child: Text(
              'Restore',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _contentWidget(VipData vip) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              bottom: 0,
              child: vip.status == VipStatus.none ? _buyView() : _vipView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vipView() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _nameView('Premium benefit'),
          SizedBox(height: 15),
          _subContentView(),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 55,
                  left: 18,
                  child: Image.asset(Assets.svipSvipPro, width: 86, height: 86),
                ),
                Positioned(
                  top: 107,
                  left: 110,
                  child: Image.asset(
                    Assets.svipSvipSucBg,
                    width: 180,
                    height: 60,
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 88,
                  child: Text(
                    'Congratulations!',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 24,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34),
                    child: Text(
                      'You are now a member and can enjoy all the premium benefits.',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyView() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: ValueListenableBuilder(
        valueListenable: UserVipTool.instance.productResultList,
        builder:
            (
              BuildContext context,
              List<VipProductData> proList,
              Widget? child,
            ) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _nameView('Premium benefit'),
                  SizedBox(height: 15),
                  _subContentView(),
                  SizedBox(height: 28),
                  _nameView('Premium plan'),
                  Wrap(
                    spacing: 0, // 主轴间距
                    runSpacing: 0, // 换行间距
                    children: List.generate(
                      proList.length,
                      (index) => _listCell(proList[index]),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'The subscription will keep renewing automatically until you decide to cancel, according to the terms and conditions. You have the right to cancel anytime. Just remember to cancel at least 24 hours prior to the renewal to prevent extra charges. Keep in mind that no refunds will be issued if the subscription term has not ended.',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 12,
                      color: Color(0x801A1A1A),
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              );
            },
      ),
    );
  }

  Widget _listCell(VipProductData mod) {
    return GestureDetector(
      onTap: () {
        for (VipProductData m in UserVipTool.instance.productResultList.value) {
          m.isSelect = false;
        }
        mod.isSelect = true;
        selectData = mod;
        if (mounted) {
          setState(() {});
        }
      },
      child: SizedBox(
        height: 80,
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: mod.isSelect ? Color(0xFFF1F6FF) : Color(0xFFF5F8FC),
                  border: Border.all(
                    color: mod.isSelect ? Color(0xFF5597FA) : Color(0xFFE1ECFF),
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 24),
                    Image.asset(
                      mod.isSelect ? Assets.svipSvipSel : Assets.svipSvipUnsel,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          mod.title,
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 10,
                            color: Color(0x801A1A1A),
                          ),
                        ),
                        Text(
                          mod.showPrice,
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF341B03),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (mod.hot)
              Positioned(
                top: 0,
                right: 12,
                child: Image.asset(Assets.svipSvipHot, width: 70, height: 36),
              ),
          ],
        ),
      ),
    );
  }

  Widget _nameView(String name) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(Assets.assetsTitleBg, width: 40, height: 14),
          ),
          Positioned(
            left: 0,
            child: Text(
              name,
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subContentView() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Color(0xFFB9D0FB), Color(0xFFF1F6FF)], // 中心到边缘颜色
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 24),
          Row(
            children: [
              Image.asset(Assets.svipSvipAdsIcon, width: 42, height: 42),
              SizedBox(width: 4),
              Text(
                'Without ads',
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            children: [
              Image.asset(Assets.svipSvipSpeedUp, width: 42, height: 42),
              SizedBox(width: 4),
              Text(
                'Accelerated',
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _userBottomV(VipData vip) {
    String titleInfo = '';
    String titleName = '';
    String time = '';
    if (vip.expiresDate != null && vip.expiresDate! > 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(vip.expiresDate!);
      time = DateFormat('yyyy-MM-dd').format(dateTime);
    }
    String price = '';
    if (UserVipTool.instance.productResultList.value.isNotEmpty) {
      for (VipProductData m in UserVipTool.instance.productResultList.value) {
        if (m.productId == vip.productId) {
          price = m.showPrice;
        }
      }
    }
    if (Platform.isIOS) {
      switch (vip.productId) {
        case 'rme_weekly':
          titleInfo =
              '$price weekly subscription with automatic renewal. Cancel at any time';
          titleName = 'Deadline: $time';
        case 'rme_yearly':
          titleInfo =
              '$price. per year with automatic renewal. You can cancel at any time';
          titleName = 'Deadline: $time';
        default:
          titleInfo = 'Lifetime validity upon purchase, no need for renewal.';
          titleName = 'You have already obtained lifetime membership.';
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 15, 24, 33),
      alignment: Alignment.center,
      // height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titleInfo,
            style: const TextStyle(
              letterSpacing: -0.5,
              fontSize: 12,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x0060E7AE),
                  Color(0xFF60E7AE),
                  Color(0x0060E7AE),
                ], // 中心到边缘颜色
                begin: Alignment(-0.5, 0),
                end: Alignment(0.5, 0),
              ),
            ),
            child: Text(
              titleName,
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => (WebPage(
                      name: '',
                      link: 'https://frameplayvid.com/terms/',
                    )),
                  );
                },
                child: Text(
                  '·Terms of service',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA11A1A1A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xA11A1A1A),
                    decorationThickness: 1.0,
                  ),
                ),
              ),
              SizedBox(width: 32),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => (WebPage(
                      name: '',
                      link: 'https://frameplayvid.com/privacy/',
                    )),
                  );
                },
                child: Text(
                  '·Privacy policy',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA11A1A1A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xA11A1A1A),
                    decorationThickness: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _normalBottomV(VipData vip) {
    String payInfo = '';
    String price = '';
    if (UserVipTool.instance.productResultList.value.isNotEmpty) {
      for (VipProductData m in UserVipTool.instance.productResultList.value) {
        if (m.productId == selectData?.productId) {
          price = m.showPrice;
        }
      }
    }
    if (Platform.isIOS) {
      switch (selectData?.productId) {
        case 'weekly':
          payInfo =
              '$price weekly subscription with automatic renewal. Cancel at any time';
        case 'annual':
          payInfo =
              '$price. per year with automatic renewal. You can cancel at any time';
        default:
          payInfo = 'Lifetime validity upon purchase, no need for renewal.';
      }
    }
    return ValueListenableBuilder(
      valueListenable: UserVipTool.instance.productResultList,
      builder:
          (BuildContext context, List<VipProductData> proList, Widget? child) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 15, 24, 33),
              alignment: Alignment.center,
              // height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    payInfo,
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _openPay();
                    },
                    child: SizedBox(
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Color(0xFF136FF9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: const TextStyle(
                                letterSpacing: -0.5,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            SizedBox(width: 12),
                            Image.asset(
                              Assets.svipSvipNext,
                              width: 22,
                              height: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => (WebPage(
                              name: '',
                              link: 'https://frameplayvid.com/terms/',
                            )),
                          );
                        },
                        child: Text(
                          '·Terms of service',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xA11A1A1A),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xA11A1A1A),
                            decorationThickness: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => (WebPage(
                              name: '',
                              link: 'https://frameplayvid.com/privacy/',
                            )),
                          );
                        },
                        child: Text(
                          '·Privacy policy',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xA11A1A1A),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xA11A1A1A),
                            decorationThickness: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
    );
  }

  void _openPay() async {
    if (selectData == null) {
      return;
    }
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: false,
    );
    await UserVipTool.instance.toGetPay(selectData);
  }
}
