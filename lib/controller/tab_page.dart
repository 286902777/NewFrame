import 'package:flutter/material.dart';
import 'package:frame/event/event_manager.dart';
import 'package:get/get.dart';
import 'package:frame/controller/set_page.dart';
import 'package:frame/controller/upload_page.dart';
import 'package:frame/source/app_key.dart';
import '../admob_max/admob_max_tool.dart';
import '../event/back_event_manager.dart';
import '../generated/assets.dart';
import '../source/Common.dart';
import 'deep_page.dart';
import 'index_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});
  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage>
    with WidgetsBindingObserver, RouteAware {
  final PageController _tabPageController = PageController();
  int _currentTabIdx = 0;
  AppLifecycleState? _lastLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // 记录上次的生命周期状态
    if (_lastLifecycleState == AppLifecycleState.paused &&
        state == AppLifecycleState.resumed) {
       if (AdmobMaxTool.adsState != AdsState.showing) {
         eventAdsSource = AdmobSource.hot_open;
         // MyUserManager.instance.restore(appStart: true);
         await AdmobMaxTool.showAdsScreen(AdsSceneType.open);
       }
    }
    _lastLifecycleState = state;
  }
  
  @override
  void initState() {
    super.initState();
    listenAppState();
    clickTabItem = (i) {
      _tabPageController.jumpToPage(i);
      setState(() {
        _currentTabIdx = i;
      });
    };

    pushDeepPageInfo = () {
      pushDeepVC();
    };

    WidgetsBinding.instance.addObserver(this);
    AdmobMaxTool.addListener(hashCode.toString(), (
        state, {
          adsType,
          ad,
          sceneType,
        }) async {
      if (state == AdsState.showing && AdmobMaxTool.scene == AdsSceneType.open) {
        String linkId = await AppKey.getString(AppKey.appLinkId) ?? '';
        BackEventManager.instance.getAdsValue(
          BackEventName.advProfit,
          apiPlatform,
          ad,
          linkId,
          '',
          '',
        );
        // if (adsType == AdsType.native) {
        //   Get.to(
        //         () => AdmobNativePage(
        //       ad: ad,
        //       sceneType: sceneType ?? MaxSceneType.open,
        //     ),
        //   )?.then((result) {
        //     AdmobMaxTool.instance.nativeDismiss(
        //       MaxState.dismissed,
        //       adsType: MaxType.native,
        //       ad: ad,
        //       sceneType: sceneType ?? MaxSceneType.open,
        //     );
        //   });
        // }
      }
      if (state == AdsState.dismissed &&
          AdmobMaxTool.scene == AdsSceneType.open) {
        if (sceneType == AdsSceneType.plus || adsType == AdsType.rewarded) {
          pushDeepVC();
        } else {
          loadPlusAds();
        }
      }
    });
    Future.delayed(Duration(milliseconds: 500), () {
      pushDeepVC();
    });
  }

  void loadPlusAds() async {
    // bool s = await AdmobMaxTool.showAdsScreen(AdsSceneType.plus);
    // if (s == false) {
    //   pushDeepVC();
    // }
  }

  void openSelectIndex(int index) {
    _tabPageController.jumpToPage(index);
    setState(() {
      _currentTabIdx = index;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    AdmobMaxTool.removeListener(hashCode.toString());
  }

  void listenAppState() {
    // AppStateEventNotifier.startListening();
    // AppStateEventNotifier.appStateStream.listen((state) async {
    //   if (state == AppState.foreground &&
    //       AdmobMaxTool.maxState != MaxState.showing) {
    //     eventAdsSource = AdsSource.hot_open;
    //     MyUserManager.instance.restore(appStart: true);
    //     await AdmobMaxTool.disPlayAdmobOrMax(MaxSceneType.open);
    //   }
    // });
  }

  void pushDeepVC() {
    if (deepLink.isNotEmpty) {
      Get.offAll(() => TabPage());
      Get.to(() => DeepPage(linkId: appLinkId))?.then((_) {
        // subscriberSource = SubscriberSource.home;
        // goCommentPage();
        // PlayerManager.showResult(true);
      });
      deepLink = '';
    }
  }

  // void goCommentPage() async {
  //   bool clickCommendStar =
  //       await AppKey.getBool(AppKey.clickCommendStar) ?? false;
  //   int numCommend = await AppKey.getInt(AppKey.numCommend) ?? 0;
  //   bool twoDay = await isShowCommentPage();
  //   if (clickCommendStar == false && numCommend < 2 && twoDay) {
  //     await AppKey.save(AppKey.numCommend, numCommend + 1);
  //     showDialog(context: context, builder: (context) => MyCommentPage());
  //   }
  // }

  // Future<bool> isShowCommentPage() async {
  //   int time = await AppKey.getInt(AppKey.commendTime) ?? 0;
  //   if (time > 0) {
  //     DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
  //     final day = Duration(days: 2);
  //     return (DateTime.now().difference(date).abs() > day);
  //   }
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: PageView(
          controller: _tabPageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [IndexPage(), UploadPage(), SetPage()],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // 外部阴影
              BoxShadow(
                color: Color(0x08000000),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent, // 禁用水波纹颜色
                highlightColor: Colors.transparent,
                dividerColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentTabIdx,
                backgroundColor: Colors.white,
                selectedItemColor: Colors.transparent,
                unselectedItemColor: Colors.transparent,
                enableFeedback: false,
                onTap: (index) {
                  openSelectIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    label: "0",
                    icon: TabBarItems(Assets.assetsIndex, false),
                    activeIcon: TabBarItems(Assets.assetsIndexSel, true),
                  ),
                  BottomNavigationBarItem(
                    label: "1",
                    icon: TabBarItems(Assets.assetsUpload, false),
                    activeIcon: TabBarItems(Assets.assetsUploadSel, true),
                  ),
                  BottomNavigationBarItem(
                    label: "2",
                    icon: TabBarItems(Assets.assetsSet, false),
                    activeIcon: TabBarItems(Assets.assetsSetSel, true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarItems extends StatelessWidget {
  final String name;
  final bool isSelected;
  const TabBarItems(this.name, this.isSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 66,
          height: 40,
          child: Image.asset(
            name,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        SizedBox(height: 6),
        Visibility(
          visible: isSelected,
          child: Container(
            width: 4,
            height: 4,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFF0C0C0C),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
      ],
    );
  }
}
