import 'package:frame/source/app_key.dart';
import 'package:frame/vip_page/user_vip_page.dart';
import 'package:frame/vip_page/user_vip_tool.dart';
import 'package:get/get.dart';

import '../controller/play_page.dart';
import '../model/videoModel.dart';
import '../model/vip_data.dart';
import 'Common.dart';

class PlayManager {
  static pushPage(VideoModel model, List<VideoModel> lists, bool recommend) {
    Get.to(() => PlayPage(currentModel: model, playList: lists))?.then((
      result,
    ) {
      if (result != null) {
        vipSource = VipSource.ad;
        showResult(result);
      }
    });
  }

  static showResult(bool result) async {
    if (result && UserVipTool.instance.vipData.value.status == VipStatus.none) {
      int? showCount = await AppKey.getInt(AppKey.vipAlertShowCount);
      if ((showCount ?? 0) < 3) {
        int? time = await AppKey.getInt(AppKey.vipAlertTime);
        if (time != null && time > 0) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
          final day = Duration(days: 1);
          if (DateTime.now().difference(date).abs() <= day) {
            return;
          }
        }
        int? playTime = await AppKey.getInt(AppKey.vipAlertPlayTime);
        if (playTime != null && playTime > 0) {
          DateTime hoursDate = DateTime.fromMillisecondsSinceEpoch(playTime);
          final hours = Duration(hours: 1);
          if (DateTime.now().difference(hoursDate).abs() <= hours) {
            return;
          }
        }

        await AppKey.save(
          AppKey.vipAlertTime,
          DateTime.now().millisecondsSinceEpoch.toInt(),
        );
        await AppKey.save(AppKey.vipAlertShowCount, (showCount ?? 0) + 1);
        vipMethod = VipMethod.auto;
        Get.to(() => UserVipPage());
      }
    }
  }
}
