import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frame/source/Common.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../generated/assets.dart';
import 'admob_max_tool.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key, required this.ad, required this.sceneType});
  final NativeAd ad;
  final AdsSceneType sceneType;

  @override
  State<NativePage> createState() => _AdmobNativePageState();
}

class _AdmobNativePageState extends State<NativePage> {
  var showTime = true.obs;
  var timeValue = AdmobMaxTool.instance.nativeTime.obs;
  var canClick = true.obs;

  Timer? _timer;

  final GlobalKey _closeKey = GlobalKey();
  final GlobalKey _adKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeValue = AdmobMaxTool.instance.middlePlayCloseTime.obs;
    if (widget.sceneType == AdsSceneType.middle) {
      canClick.value =
          Random().nextInt(100) >= AdmobMaxTool.instance.middlePlayCloseClick;
    } else {
      canClick.value =
          Random().nextInt(100) >= AdmobMaxTool.instance.nativeClick;
    }
    startTime();
    clickNativeAction = () {
      canClick.value = true;
    };
  }

  void _checkClick(Offset globalPos) {
    final ignoreRenderBox =
        _closeKey.currentContext?.findRenderObject() as RenderBox;
    final parentRenderBox =
        _adKey.currentContext?.findRenderObject() as RenderBox;
    final relativePos = parentRenderBox.globalToLocal(globalPos);
    if (ignoreRenderBox.paintBounds.contains(relativePos)) {
      // 触发逻辑
      canClick.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: widget.sceneType == AdsSceneType.middle
            ? Colors.transparent
            : Color(0xA6000000),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: AspectRatio(
              aspectRatio: 6 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.hardEdge,
                child: GestureDetector(
                  key: _adKey,
                  onTapDown: (details) => _checkClick(details.globalPosition),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdWidget(ad: widget.ad),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Obx(
                          () => Visibility(
                            visible: !showTime.value,
                            child: IgnorePointer(
                              ignoring: !canClick.value,
                              child: GestureDetector(
                                key: _closeKey,
                                onTap: () {
                                  Get.back(result: true);
                                },
                                child: Image.asset(
                                  Assets.assetsNaviteClose,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Obx(
                          () => Visibility(
                            visible: showTime.value,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0x80000000),
                              ),
                              child: Text(
                                '${timeValue.value}',
                                style: const TextStyle(
                                  letterSpacing: -0.5,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (timeValue.value > 0) {
        timeValue.value--;
      } else {
        showTime.value = false;
        time.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.ad.dispose();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }
}
