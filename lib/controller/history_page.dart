import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../event/event_manager.dart';
import '../generated/assets.dart';
import '../model/videoModel.dart';
import '../source/AppBasePage.dart';
import '../source/AppDataManager.dart';
import '../source/Common.dart';
import '../source/CusToast.dart';
import '../view/delete_alert_page.dart';
import '../view/history_cell.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Common.instance.initTracking();
    eventSource = BackEventSource.history;
    EventManager.instance.enventUpload(EventApi.historyExpose, null);
  }

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: _gardView(),
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
          SizedBox(width: 12),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.assetsBack, width: 32),
          ),
        ],
      ),
      actions: [
        Container(
          width: 92,
          height: 32,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Color(0x40A9CBFF), // 颜色放在 decoration 中
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              _displayAlert();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(Assets.assetsDeleteNav, width: 18),
                Text(
                  'Delete All',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _gardView() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: Get.width,
          height: 44,
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                  'History',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF17132C),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: AppDataBase.instance.historyItems.length,
              itemBuilder: (context, index) {
                return HistoryCell(
                  model: AppDataBase.instance.historyItems[index],
                  onDelete: () {
                    VideoModel m = AppDataBase.instance.historyItems[index];
                    m.playTime = 0;
                    m.isHistory = 0;
                    AppDataBase.instance.updateVideoModel(m);
                    CusToast.show(
                      message: 'Removal Complete',
                      type: CusToastType.success,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _displayAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击背景是否关闭
      builder: (context) => DeleteAlertPage(),
    ).then((result) {
      if (result) {
        for (VideoModel m in AppDataBase.instance.historyItems) {
          m.playTime = 0;
          m.isHistory = 0;
          AppDataBase.instance.updateVideoModel(m);
        }
      }
    });
  }
}
