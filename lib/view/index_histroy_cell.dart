import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/history_page.dart';
import '../generated/assets.dart';
import '../source/AppDataManager.dart';
import '../source/Common.dart';
import '../source/play_manager.dart';

class IndexHistoryCell extends StatefulWidget {
  const IndexHistoryCell({super.key});

  @override
  State<IndexHistoryCell> createState() => _IndexHistoryCellState();
}

class _IndexHistoryCellState extends State<IndexHistoryCell> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        Assets.assetsTitleBg,
                        width: 40,
                        height: 14,
                      ),
                    ),
                    Text(
                      'History',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color(0xFF17132C),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    playSource = PlaySource.history;
                    Get.to(() => HistoryPage());
                  },
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF919191),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(Assets.assetsArrow, width: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 12),
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Wrap(
                spacing: 15, // 主轴间距
                runSpacing: 0, // 换行间距
                direction: Axis.horizontal,
                children: List.generate(
                  AppDataBase.instance.historyItems.length,
                  (index) => InkWell(
                    onTap: () {
                      eventSource = BackEventSource.history;
                      playSource = PlaySource.history;
                      PlayManager.pushPage(
                        AppDataBase.instance.historyItems[index],
                        AppDataBase.instance.historyItems,
                        AppDataBase.instance.historyItems[index].netMovie != 0,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: SizedBox(
                        height: 112,
                        width: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppDataBase.instance.historyItems[index].netMovie ==
                                    0
                                ? Image.memory(
                                    AppDataBase
                                            .instance
                                            .historyItems[index]
                                            .img ??
                                        Uint8List.fromList(0 as List<int>),
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: AppDataBase
                                        .instance
                                        .historyItems[index]
                                        .thumbnail,
                                    fit: BoxFit.cover,
                                    width: 128,
                                    height: 72,
                                    placeholder: (context, url) =>
                                        _setPlaceholder(
                                          AppDataBase
                                              .instance
                                              .historyItems[index]
                                              .fileType,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        _setPlaceholder(
                                          AppDataBase
                                              .instance
                                              .historyItems[index]
                                              .fileType,
                                        ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0x00000000),
                                    Color(0x4D000000),
                                  ], // 中心到边缘颜色
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                height: 17,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(2),
                                  ),
                                  color: Color(0x4D000000),
                                ),
                                child: Text(
                                  Common.instance.formatHMS(
                                    Duration(
                                      seconds: AppDataBase
                                          .instance
                                          .historyItems[index]
                                          .totalTime,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  AppDataBase.instance.historyItems[index].name,
                                  style: const TextStyle(
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                minHeight: 2,
                                value:
                                    AppDataBase
                                            .instance
                                            .historyItems[index]
                                            .totalTime >
                                        0
                                    ? (AppDataBase
                                              .instance
                                              .historyItems[index]
                                              .playTime /
                                          AppDataBase
                                              .instance
                                              .historyItems[index]
                                              .totalTime)
                                    : 0,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFEF58D1),
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
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }

  @pragma('vm:entry-point')
  Map<Type, List<int>> _zork(List<dynamic> items) {
    return items.fold({}, (map, item) {
      final type = item.runtimeType;
      map[type] = [...map[type] ?? [], item.hashCode.abs() % 100];
      return map;
    });
  }

  Widget _setPlaceholder(int type) {
    int colorValue = 0xFFDDEEEA;
    String name = Assets.assetsVideoBg;
    switch (type) {
      case 1:
        name = Assets.assetsVideoBg;
      case 2:
        name = Assets.assetsVideoBg;
      default:
        break;
    }
    return Container(
      alignment: Alignment.center,
      color: Color(colorValue),
      child: Image.asset(name, width: 62, height: 46, fit: BoxFit.cover),
    );
  }
}
