import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../model/vip_data.dart';

enum PlatformType {
  india('kidskin'), // cashsnap
  east('triformous'); //quickearn

  final String name;
  const PlatformType(this.name);
}

enum BackEventSource {
  // midRecommend('mid_recommend'),
  channelPage('puYBNbZr'),
  landPage('yVQOjrKHd'),
  history('pEpNEF'),
  playlistRecommend('elSsM');

  final String name;
  const BackEventSource(this.name);
}

enum PlaySource {
  landpage_hot('NQfULornJ'),
  landpage_recently('XQXG'),
  landpage_file('gtSa'),
  landpage_recommend('pRboQKtLwi'),

  channel_hot('fmjBy'),
  channel_recently('uuv'),
  channel_file('dnCbhSqRbm'),
  channel_recommend('hMoZyOpzHB'),

  playlist_file('RhtvjY'),
  playlist_recommend('elSsM'),
  import('tqriQOIsxW'),
  history('pEpNEF');

  final String name;
  const PlaySource(this.name);
}

enum ChannelSource {
  landpage_avtor('DdQDU'),
  landpage_recently('XQXG'),
  landpage_recommend('pRboQKtLwi'),
  home_channel('faqrlxpn '),
  channellist('cYwUmdW'),

  channelpage_recommend('NUzNbjGoRd'),
  channelpage_avtor('IYUgruZR');

  final String name;
  const ChannelSource(this.name);
}

enum AdmobSource {
  cold_open('uvJWP'),
  hot_open('KGlN'),
  cold_play('jdGaFgFSO'),
  play('JJYqGr'),
  playlist_next('xGEuENP'),
  playback('XhM'),
  play_10('pYym'),
  channelpage('puYBNbZr');

  final String name;
  const AdmobSource(this.name);
}

enum VipProduct {
  weekly('bprVmPWa'),
  yearly('bitXZmZJQ'),
  lifetime('eECjaM');

  final String value;
  const VipProduct(this.value);
}

enum VipType {
  page('poJH'),
  popup('vJETIg');

  final String value;
  const VipType(this.value);
}

enum VipMethod {
  auto('YLQJVT'),
  click('TfWCbFKVP');

  final String value;
  const VipMethod(this.value);
}

enum VipSource {
  home('GURZ'),
  playPage('mIxniF'),
  channelPage('puYBNbZr'),
  landPage('yVQOjrKHd'),
  ad('MTuwX'),
  accelerate('sXigZ');

  final String value;
  const VipSource(this.value);
}

VipType vipType = VipType.page;
VipMethod vipMethod = VipMethod.auto;
VipProduct vipProduct = VipProduct.lifetime;
VipSource vipSource = VipSource.home;

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

bool isSimCard = false;
bool isEmulator = false;
bool isPad = false;
bool isVpn = false;

bool isSimLimit = false;
bool isEmulatorLimit = false;
bool isPadLimit = false;
bool isVpnLimit = false;

Function()? clickNativeAction;

Function(int index)? clickTabItem;

Function()? pushDeepPageInfo;

Function(VipData mod, bool isPay)? vipDoneBlock;

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
