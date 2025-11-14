import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import '../generated/assets.dart';

enum CusToastType { none, success, fail, waring }

class CusToast {
  static void show({
    required String message,
    ToastPosition position = ToastPosition.center,
    CusToastType type = CusToastType.none,
    Color textColor = Colors.white,
    double fontSize = 14,
    double radius = 16,
    Color bgColor = const Color(0xFF274065),
    Duration duration = const Duration(seconds: 2),
  }) {
    showToastWidget(
      dismissOtherToast: true,
      handleTouch: true,
      FractionallySizedBox(
        child: Container(
          color: Color(0xA6000000),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 280), // 设置最大宽度为200
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.all(Radius.circular(radius)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: type != CusToastType.none,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          type == CusToastType.success
                              ? Assets.assetsSuccess
                              : (type == CusToastType.fail
                                    ? Assets.assetsFail
                                    : Assets.assetsRepeat),
                          width: 24,
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      // maxLines: 10,
                    ),
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
