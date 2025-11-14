import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

enum PlatformType {
  india('kidskin'), // cashsnap
  east('triformous'); //quickearn

  final String name;
  const PlatformType(this.name);
}

enum BackEventSource {
  // midRecommend('mid_recommend'),
  channelPage('xsdf'),
  landPage('sdfa'),
  history('sdfe'),
  playlistRecommend('sews');

  final String name;
  const BackEventSource(this.name);
}

enum PlaySource {
  landpage_hot('we'),
  landpage_recently('wer'),
  landpage_file('123'),
  landpage_recommend('213'),

  channel_hot('432'),
  channel_recently('124'),
  channel_file('123'),
  channel_recommend('24'),

  playlist_file('2412'),
  playlist_recommend('12412324'),
  import('wxw'),
  history('12zq');

  final String name;
  const PlaySource(this.name);
}

enum ChannelSource {
  landpage_avtor('xsjwxX1NXYi'),
  landpage_recently('bsekIDPmk'),
  landpage_recommend('sdfEcB'),
  home_channel('sdfPwQUkzHtZ '),
  channellist('xsUWvcMm'),

  channelpage_recommend('sfWYhy'),
  channelpage_avtor('sgSIoGalmZZ');

  final String name;
  const ChannelSource(this.name);
}

enum AdmobSource {
  cold_open('sd'),
  hot_open('sdfs'),
  cold_play('sw'),
  play('taxfZ'),
  playlist_next('bsx'),
  playback('sdfa'),
  play_10('obhZsdHj'),
  channelpage('MaUasaFIrJ');

  final String name;
  const AdmobSource(this.name);
}

PlatformType apiPlatform = PlatformType.india;
BackEventSource eventSource = BackEventSource.landPage;
PlaySource playSource = PlaySource.landpage_hot;
ChannelSource channelSource = ChannelSource.landpage_avtor;
AdmobSource eventAdsSource = AdmobSource.cold_open;

String appLinkId = '';
String deepLink = '';
String app_Name = 'Frame';
String app_Bunlde_Id = 'com.frame.lumistream';
bool isFullScreen = false;
bool isDeepComment = false;
String playFileId = '';
bool isDeepLink = false;

Function()? clickNativeAction;

Function(int index)? clickTabItem;

Function()? pushDeepPageInfo;

class Common {
  static Common instance = Common();

  bool netStatus = false;

  String disPlayTime(Duration duration) {
    bool isNa = duration.isNegative;
    Duration dur = duration.abs();
    String tow(int n) => n.toString().padLeft(2, '0');
    final h = tow(dur.inHours);
    final m = tow(dur.inMinutes.remainder(60));
    final s = tow(dur.inSeconds.remainder(60));
    if (dur.inHours > 0) {
      return '[${isNa ? '-' : '+'}$h:$m:$s]';
    } else {
      return '[${isNa ? '-' : '+'}$m:$s]';
    }
  }

  String formatHMS(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(duration.inHours);
    final m = two(duration.inMinutes.remainder(60));
    final s = two(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$h:$m:$s';
    } else {
      return '$m:$s';
    }
  }

  void networkStatus() {
    Connectivity().onConnectivityChanged.listen((result) {
      netStatus = result.first != ConnectivityResult.none;
    });
  }

  Future<void> initTracking() async {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await AppTrackingTransparency.requestTrackingAuthorization();
    });
  }

  String countFile(int size) {
    if (size / 1024 < 1) {
      return '${size}B';
    } else if (size / 1024 < 1024) {
      String fileSize = (size / 1024).toStringAsFixed(2);
      return '${fileSize}KB';
    } else if (size / 1024 / 1024 < 1024) {
      String fileSize = (size / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}MB';
    } else {
      String fileSize = (size / 1024 / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}GB';
    }
  }
}
