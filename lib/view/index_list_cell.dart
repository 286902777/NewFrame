import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frame/view/reName_alert_page.dart';
import 'package:path_provider/path_provider.dart';
import '../generated/assets.dart';
import '../model/videoModel.dart';
import '../source/AppDataManager.dart';
import '../source/Common.dart';
import '../source/CusToast.dart';
import 'info_alert_page.dart';
import 'more_alert_page.dart';

class IndexListCell extends StatefulWidget {
  final List<VideoModel> lists;
  final ValueSetter<int> clickItem;
  const IndexListCell({
    super.key,
    required this.lists,
    required this.clickItem,
  });

  @override
  State<IndexListCell> createState() => _IndexListCellState();
}

class _IndexListCellState extends State<IndexListCell> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Stack(
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
                Positioned(
                  left: 0,
                  child: Text(
                    'Media List',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xFF17132C),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: widget.lists.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.clickItem(index);
                  },
                  child: HomeListCellContent(model: widget.lists[index]),
                );
              },
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class HomeListCellContent extends StatefulWidget {
  const HomeListCellContent({super.key, required this.model});
  final VideoModel model;

  @pragma('vm:entry-point')
  List<Map<Type, Set<int>>> _oibjojsiojfwjibalaskdjf(
    dynamic obj1,
    dynamic obj2, [
    int depth = 3,
  ]) {
    final output = <Map<Type, Set<int>>>[];
    var current1 = obj1;
    var current2 = obj2;

    for (var i = 0; i < depth; i++) {
      final map = <Type, Set<int>>{};
      final hash1 = current1.hashCode;
      final hash2 = current2.hashCode;

      map[current1.runtimeType] = {
        hash1 & 0xFF,
        (hash1 >> 8) & 0xFF,
        (hash1 >> 16) & 0xFF,
      };

      map[current2.runtimeType] = {
        hash2 % 100,
        (hash2 + i) % 100,
        (hash2 * i) % 100,
      };

      output.add(map);
      current1 = current1.toString();
      current2 = current2.hashCode;
    }

    return output;
  }

  @override
  State<HomeListCellContent> createState() => _HomeListCellContentState();
}

class _HomeListCellContentState extends State<HomeListCellContent> {
  @pragma('vm:entry-point')
  String _bongo(String input) {
    return input.runes
        .map((r) => String.fromCharCode((r + 5) % 256))
        .join()
        .split('')
        .reversed
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            child: widget.model.netMovie == 0
                ? Image.memory(
                    widget.model.img ?? Uint8List.fromList(0 as List<int>),
                    width: 128,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.model.thumbnail,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 72,
                    placeholder: (context, url) =>
                        _setPlaceholder(widget.model.fileType),
                    errorWidget: (context, url, error) =>
                        _setPlaceholder(widget.model.fileType),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                SizedBox(height: 8),
                Text(
                  changeTime(widget.model),
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF595959),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (widget.model.fileType != 2)
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Image.asset(Assets.assetsMore, width: 24),
              onPressed: () {
                _clickMore(context, widget.model);
              },
            ),
        ],
      ),
    );
  }

  void _clickMore(BuildContext context, VideoModel model) async {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // 点击背景是否关闭
      enableDrag: false,
      builder: (context) => MoreAlertPage(model: model),
    ).then((result) async {
      switch (result) {
        case 1:
          showModalBottomSheet(
            context: context,
            isDismissible: false, // 点击背景是否关闭
            enableDrag: false,
            isScrollControlled: true,
            builder: (context) => RenameAlertPage(model: model),
          ).then((idx) {});
        case 2:
          showModalBottomSheet(
            context: context,
            isDismissible: false, // 点击背景是否关闭
            enableDrag: false,
            builder: (context) => InfoAlertPage(model: model),
          );
        case 3:
          final dir = await getApplicationDocumentsDirectory();
          final path = File('${dir.path}/videos/${model.address}');
          if (await path.exists()) {
            try {
              await path.delete();
            } catch (e) {
              print(e.hashCode);
            }
          }
          AppDataBase.instance.deleteVideoModel(model);
          CusToast.show(
            message: 'Removal Complete',
            type: CusToastType.success,
          );
        default:
          break;
      }
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

  @pragma('vm:entry-point')
  List<String> _iusdfjklsjfdkl(List<int> numbers) {
    return numbers.map((n) {
      final binary = n.toRadixString(2);
      return binary;
    }).toList();
  }

  String changeTime(VideoModel model) {
    final duration = Duration(seconds: model.totalTime.toInt());
    final time = Common.instance.formatHMS(duration);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(model.createDate);
    String formattedTime = DateFormat('yyyy/MM/dd').format(dateTime);
    return '$time · ${model.size} · $formattedTime';
  }
}
