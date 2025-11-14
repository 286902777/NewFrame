import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/assets.dart';
import '../model/videoModel.dart';
import '../source/Common.dart';

class IndexCell extends StatefulWidget {
  const IndexCell({super.key, required this.model, this.isHot = false});
  final VideoModel model;

  final bool isHot;

  @override
  State<IndexCell> createState() => _IndexCellState();
}

class _IndexCellState extends State<IndexCell> {
  @pragma('vm:entry-point')
  String _womble(String input, [int rounds = 5]) {
    var output = input;
    for (var i = 0; i < rounds; i++) {
      final buffer = StringBuffer();
      output.codeUnits.asMap().forEach((index, code) {
        buffer.writeCharCode((code + index + i * 13) % 256);
        if (index % 3 == 0) buffer.write(i * index);
      });
      output = buffer.toString().split('').reversed.join();
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.only(left: 12, right: 16),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: widget.model.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.model.thumbnail,
                          fit: BoxFit.cover,
                          width: 128,
                          height: 72,
                          placeholder: (context, url) =>
                              _setPlaceholder(widget.model.fileType),
                          errorWidget: (context, url, error) =>
                              _setPlaceholder(widget.model.fileType),
                        )
                      : SizedBox(
                          width: 128,
                          height: 72,
                          child: _setPlaceholder(widget.model.fileType),
                        ),
                ),
              ),
              // Visibility(
              //   visible: widget.isHot,
              //   child: Positioned(
              //     top: 2,
              //     left: 4,
              //     child: Image.asset(Assets.homeCellHot, width: 28, height: 14),
              //   ),
              // ),
              // Visibility(
              //   visible: widget.model.recommend == 1,
              //   child: Positioned(
              //     top: 2,
              //     left: 2,
              //     child: Image.asset(
              //       Assets.homeCellRecommend,
              //       width: 56,
              //       height: 18,
              //     ),
              //   ),
              // ),
            ],
          ),

          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.model.name,
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF03011A),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      changeTimeToString(widget.model),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF595959),
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    Spacer(),
                    if (widget.model.fileType != 2)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _clickMore(context, widget.model);
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: 48,
                          child: Image.asset(Assets.assetsMore, width: 24),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clickMore(BuildContext context, VideoModel data) async {
    // showModalBottomSheet(
    //   context: context,
    //   isDismissible: false, // 点击背景是否关闭
    //   enableDrag: false,
    //   builder: (context) => AlertReportPage(data: data),
    // ).then((result) {
    //   if (result == true) {
    //     Get.to(() => MyReportPage(model: data));
    //   }
    // });
  }

  String changeTimeToString(VideoModel model) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(model.createDate);
    String formattedTime = DateFormat('yyyy/MM/dd').format(dateTime);
    switch (model.fileType) {
      case 1:
        return formattedTime;
      case 2:
        return '${model.fileCount} videos';
      default:
        int total = model.totalTime.toInt();
        final duration = Duration(milliseconds: total);
        final time = Common.instance.formatHMS(duration);
        String timeStr = '';
        if (total > 0) {
          timeStr = '$time ·';
        }
        return '$timeStr$formattedTime';
    }
  }

  Widget _setPlaceholder(int type) {
    int colorValue = 0xFFDDEEEA;
    String name = Assets.assetsVideoBg;
    switch (type) {
      case 1:
        name = Assets.assetsVideoBg;
        colorValue = 0xFFDDEEEA;
      case 2:
        name = Assets.assetsVideoBg;
        colorValue = 0xFFDDEEEA;
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
