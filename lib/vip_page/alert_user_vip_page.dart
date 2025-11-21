import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frame/source/Common.dart';
import 'package:frame/source/fire_manager.dart';
import 'package:frame/vip_page/alert_user_vip_fail_page.dart';
import 'package:frame/vip_page/user_vip_tool.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../generated/assets.dart';
import '../model/vip_data.dart';
import '../source/web_page.dart';

class AlertUserVipPage extends StatefulWidget {
  const AlertUserVipPage({super.key});

  @override
  State<AlertUserVipPage> createState() => _AlertUserVipPageState();
}

class _AlertUserVipPageState extends State<AlertUserVipPage> {
  List<VipProductData> lists = [];
  VipProductData? selectData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
    vipDoneBlock = (mod, pay) {
      if (mod.purchaseDetails?.status != PurchaseStatus.canceled &&
          pay == true) {
        if (mod.ok == false) {
          showDialog(
            context: context,
            builder: (context) => AlertUserVipFailPage(),
          );
        } else {
          Get.back();
        }
      }
    };
  }

  void addData() async {
    if (UserVipTool.instance.productResultList.value.isEmpty) {
      await UserVipTool.instance.queryProductInfo();
    }

    // VipProductData sx = VipProductData(
    //   productId: 'ssd',
    //   title: 'year',
    //   productInfo: 'productInfo',
    //   price: 19.99,
    //   showPrice: '${'\$'}19.99',
    //   currency: '*',
    //   isSelect: true,
    //   hot: true,
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
    // lists.add(sx);
    // lists.add(ssx);

    for (VipProductData m in UserVipTool.instance.productResultList.value) {
      if (m.productId != UserVipIdKey.year.value) {
        lists.add(m);
      }
    }

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xA6000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _contentV(),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(Assets.svipSvipClose, width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  Widget _contentV() {
    return ValueListenableBuilder(
      valueListenable: UserVipTool.instance.vipData,
      builder: (BuildContext context, VipData vip, Widget? child) {
        return Container(
          width: 300,
          height: 328,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/svip/svip_pop_small.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 76, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),

                child: Column(
                  children: [
                    if (lists.isNotEmpty) _listCell(lists.first),
                    if (lists.length >= 2) _listCell(lists.last),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () async {
                          EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.clear,
                            dismissOnTap: false,
                          );
                          await UserVipTool.instance.toGetPay(selectData);
                        },
                        child: SizedBox(
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(21),
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
                    ),
                    SizedBox(height: 12),
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
                              color: Color(0xA11A1A1A),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xA11A1A1A),
                              decorationThickness: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
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
                  //       ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _listCell(VipProductData mod) {
    return GestureDetector(
      onTap: () {
        for (VipProductData m in lists) {
          m.isSelect = false;
        }
        mod.isSelect = true;
        selectData = mod;
        if (mounted) {
          setState(() {});
        }
      },
      child: SizedBox(
        height: 78,
        child: Stack(
          children: [
            Positioned(
              top: 14,
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
}
