import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frame/controller/set_page.dart';
import 'package:frame/controller/upload_page.dart';
import 'package:frame/source/app_key.dart';
import '../generated/assets.dart';
import '../source/Common.dart';
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

    // getDeepLinkInfo = () {
    //   openDeepPage();
    // };

    WidgetsBinding.instance.addObserver(this);
    // MaxManager.addListener(hashCode.toString(), (
    //     state, {
    //       adsType,
    //       ad,
    //       sceneType,
    //     }) async {
    //   if (state == MaxState.showing && MaxManager.scene == MaxSceneType.open) {
    //     String linkId = await MyUserData.getString(MyUserData.appLinkId) ?? '';
    //     ServiceEvent.instance.getAdsValue(
    //       BackEventName.advProfit,
    //       apiPlatform,
    //       ad,
    //       linkId,
    //       '',
    //       '',
    //     );
    //     if (adsType == MaxType.native) {
    //       Get.to(
    //             () => AdmobNativePage(
    //           ad: ad,
    //           sceneType: sceneType ?? MaxSceneType.open,
    //         ),
    //       )?.then((result) {
    //         MaxManager.instance.nativeDismiss(
    //           MaxState.dismissed,
    //           adsType: MaxType.native,
    //           ad: ad,
    //           sceneType: sceneType ?? MaxSceneType.open,
    //         );
    //       });
    //     }
    //   }
    //   if (state == MaxState.dismissed &&
    //       MaxManager.scene == MaxSceneType.open) {
    //     if (sceneType == MaxSceneType.plus || adsType == MaxType.rewarded) {
    //       openDeepPage();
    //     } else {
    //       loadPlusAds();
    //     }
    //   }
    // });
    // Future.delayed(Duration(milliseconds: 500), () {
    //   openDeepPage();
    // });
  }

  // void loadPlusAds() async {
  //   bool s = await MaxManager.disPlayAdmobOrMax(MaxSceneType.plus);
  //   if (s == false) {
  //     openDeepPage();
  //   }
  // }

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
    // MaxManager.removeListener(hashCode.toString());
  }

  void listenAppState() {
    // AppStateEventNotifier.startListening();
    // AppStateEventNotifier.appStateStream.listen((state) async {
    //   if (state == AppState.foreground &&
    //       MaxManager.maxState != MaxState.showing) {
    //     eventAdsSource = AdsSource.hot_open;
    //     MyUserManager.instance.restore(appStart: true);
    //     await MaxManager.disPlayAdmobOrMax(MaxSceneType.open);
    //   }
    // });
  }

  // void openDeepPage() {
  //   if (deepLink.isNotEmpty) {
  //     Get.offAll(() => MyTabbarPage());
  //     Get.to(() => MyDeepPage(linkId: appLinkId))?.then((_) {
  //       subscriberSource = SubscriberSource.home;
  //       goCommentPage();
  //       PlayerManager.showResult(true);
  //     });
  //     deepLink = '';
  //   }
  // }

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
