import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frame/source/AppDataManager.dart';
import 'package:frame/source/Common.dart';
import 'package:frame/source/fire_manager.dart';
import 'package:frame/source/start_page.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:oktoast/oktoast.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<PageRoute> routeObserver = RouteObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Get.put(AppDataBase());
  await FireManager.instance.addConfig();
  Common.instance.initTracking();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        title: 'Frame',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          appBarTheme: AppBarTheme(
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
              //安卓底部系统导航条
              systemNavigationBarColor: Colors.transparent,
              //安卓底部系统导航条
              systemNavigationBarIconBrightness: Brightness.light,
            ), // 状态栏字体颜色（dark: 白色，light: 黑色）
            color: Colors.white,
          ),
        ),
        home: StartPage(),
        builder: EasyLoading.init(),
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
