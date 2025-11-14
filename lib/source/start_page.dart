import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frame/controller/tab_page.dart';
import '../generated/assets.dart';
import 'Common.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Timer? _timer;
  double startTime = 7;
  double totalTime = 7;
  var progress = 0.0.obs;
  bool isSetRoot = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Common.instance.networkStatus();
    startCountTime();
    // showGMPConfig();
    // EventManager.instance.session();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/app_bg.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 220),
                Image.asset(Assets.assetsLogo48, width: 48, height: 48),
                SizedBox(height: 12),
                Text(
                  'Frame',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF17132C),
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                Text(
                  'resource loading…',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    color: Color(0xFF242038),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    child: Obx(
                      () => LinearProgressIndicator(
                        value: progress.value,
                        backgroundColor: Color(0x4D202020),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFEF58D1),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void startCountTime() async {
    // bool noStart = await UserInfo.getBool(UserInfo.onceInstallApp) ?? false;
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (startTime > 0) {
        progress.value = (totalTime - startTime) / totalTime;
        setState(() {
          startTime = startTime - 0.1;
        });
      } else {
        rootVC();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void rootVC() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    if (isSetRoot) {
      return;
    }
    isSetRoot = true;
    // MaxManager.removeListener(hashCode.toString());
    Get.offAll(() => TabPage());
  }

  void requestData() async {
    // dynamic openSuc = await MaxManager.initAdmobOrMax(MaxSceneType.open);
    // MaxManager.initAdmobOrMax(MaxSceneType.play);
    // MaxManager.initAdmobOrMax(MaxSceneType.channel);
    // bool noStart = await MyUserData.getBool(MyUserData.onceInstallApp) ?? false;
    // if (noStart == true) {
    //   if (isSetRoot == false) {
    //     if (openSuc != null) {
    //       await MaxManager.disPlayAdmobOrMax(MaxSceneType.open);
    //     } else {
    //       displayPlusAds();
    //     }
    //   }
    // } else {
    //   await MyUserData.save(MyUserData.onceInstallApp, true);
    // }
  }

  // Future<bool> isPrivacyOptionsRequired() async {
  //   return await ConsentInformation.instance
  //       .getPrivacyOptionsRequirementStatus() ==
  //       PrivacyOptionsRequirementStatus.required;
  // }
  //
  // void showGMPConfig() async {
  //   bool install = await UserInfo.getBool(UserInfo.onceInstallApp) ?? false;
  //   bool requ = await isPrivacyOptionsRequired();
  //   if (requ == false) {
  //     // ConsentInformation.instance.reset();
  //     // ConsentDebugSettings debugSettings = ConsentDebugSettings(
  //     //   debugGeography: DebugGeography.debugGeographyEea,
  //     //   testIdentifiers: ["61F857D9-E17F-4327-A20D-80039873F64B"],
  //     // );
  //     //
  //     // ConsentRequestParameters params = ConsentRequestParameters(
  //     //   consentDebugSettings: debugSettings,
  //     // );
  //
  //     final params = ConsentRequestParameters();
  //
  //     // Request an update to consent information on every app launch.
  //     ConsentInformation.instance.requestConsentInfoUpdate(
  //       params,
  //           () async {
  //         ConsentForm.loadAndShowConsentFormIfRequired((
  //             loadAndShowError,
  //             ) async {
  //           if (loadAndShowError != null) {
  //             if (install == false) {
  //               setRootPage();
  //             }
  //             await UserInfo.save(UserInfo.onceInstallApp, true);
  //           } else {
  //             final status =
  //             await ConsentInformation.instance.getConsentStatus();
  //             final config = RequestConfiguration(
  //               // 对于欧盟用户未同意的情况
  //               tagForUnderAgeOfConsent:
  //               status == ConsentStatus.required
  //                   ? TagForUnderAgeOfConsent.yes
  //                   : null,
  //             );
  //             MobileAds.instance.updateRequestConfiguration(config);
  //             if (install == false) {
  //               setRootPage();
  //             }
  //             await UserInfo.save(UserInfo.onceInstallApp, true);
  //           }
  //         });
  //       },
  //           (FormError error) {
  //         print('=--=-=-=-=-=-=-$error.message');
  //         // setRootPage();
  //       },
  //     );
  //   }
  // }
}
