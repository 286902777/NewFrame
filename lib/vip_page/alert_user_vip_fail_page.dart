import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../generated/assets.dart';

class AlertUserVipFailPage extends StatefulWidget {
  const AlertUserVipFailPage({super.key});

  @override
  State<AlertUserVipFailPage> createState() => _AlertUserVipFailPageState();
}

class _AlertUserVipFailPageState extends State<AlertUserVipFailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Color(0xA6000000),
      child: Container(
        width: 218,
        height: 104,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Color(0xFFB4D1FF),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Image.asset(Assets.svipSvipFail, width: 28, height: 28),
            SizedBox(height: 12),
            Text(
              'Payment failure',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
