import 'package:get/get.dart';
import '../controller/play_page.dart';
import '../model/videoModel.dart';

class PlayManager {
  static pushPage(VideoModel model, List<VideoModel> lists, bool recommend) {
    Get.to(() => PlayPage(currentModel: model, playList: lists))?.then((
      result,
    ) {
      // if (result != null) {
      //   subscriberSource = SubscriberSource.ad;
      //   showResult(result);
      // }
    });
  }

  // static showResult(bool result) async {
  //   if (result &&
  //       MyUserManager.instance.vipData.value.status == SubscriberStatus.none) {
  //     int? showCount = await MyUserData.getInt(MyUserData.vipAlertShowCount);
  //     if ((showCount ?? 0) < 3) {
  //       int? time = await MyUserData.getInt(MyUserData.vipAlertTime);
  //       if (time != null && time > 0) {
  //         DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
  //         final day = Duration(days: 1);
  //         if (DateTime.now().difference(date).abs() <= day) {
  //           return;
  //         }
  //       }
  //       int? playTime = await MyUserData.getInt(MyUserData.vipAlertPlayTime);
  //       if (playTime != null && playTime > 0) {
  //         DateTime hoursDate = DateTime.fromMillisecondsSinceEpoch(playTime);
  //         final hours = Duration(hours: 1);
  //         if (DateTime.now().difference(hoursDate).abs() <= hours) {
  //           return;
  //         }
  //       }
  //
  //       await MyUserData.save(
  //         MyUserData.vipAlertTime,
  //         DateTime.now().millisecondsSinceEpoch.toInt(),
  //       );
  //       await MyUserData.save(
  //         MyUserData.vipAlertShowCount,
  //         (showCount ?? 0) + 1,
  //       );
  //       subscriberMethod = SubscriberMethod.auto;
  //       Get.to(() => MyUserPage());
  //     }
  //   }
  // }
}
