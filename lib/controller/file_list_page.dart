import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frame/model/fileModel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../event/http_manager.dart';
import '../generated/assets.dart';
import '../model/videoModel.dart';
import '../source/AppBasePage.dart';
import '../source/AppDataManager.dart';
import '../source/Common.dart';
import '../source/CusToast.dart';
import '../source/RefreshPage.dart';
import '../source/play_manager.dart';
import '../view/index_cell.dart';
import 'image_page.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({
    super.key,
    required this.userId,
    required this.folderId,
    required this.name,
    required this.recommend,
    required this.platform,
    required this.linkId,
  });
  final String userId;
  final String folderId;
  final String name;
  final int recommend;
  final int platform;
  final String linkId;

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  final RefreshController _refreshController = RefreshController();

  final List<VideoModel> _dbDatabase = AppDataBase.instance.items;

  List<VideoModel> lists = [];
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNetworkData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  Future requestNetworkData() async {
    HttpManager.getRequest(
      ApiKey.folder,
      widget.platform == 0 ? PlatformType.india : PlatformType.east,
      '/${widget.userId}/${widget.folderId}',
      true,
      para: {'meature': '$page', 'shopmaid': '20'},
      successHandle: (data) {
        if (data != null) {
          FileModel model = fileModelFromJson(data);
          if (model.files.isNotEmpty) {
            replaceModel(model);
            page = page + 1;
          } else {
            _refreshController.loadNoData();
          }
        }
        _refreshController.loadComplete();
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          requestNetworkData();
        } else {
          _refreshController.loadFailed();
          CusToast.show(message: msg, type: CusToastType.fail);
        }
      },
    );
  }

  void replaceModel(FileModel model) {
    for (FileListModel item in model.files) {
      VideoModel videoM = VideoModel(
        name: item.disPlayName.ritchey,
        linkId: widget.linkId,
        movieId: item.id,
        size: Common.instance.countFile(item.fileMeta.size),
        ext: item.fileMeta.extension,
        netMovie: 1,
        createDate: item.updateTime,
        thumbnail: item.fileMeta.thumbnail,
        fileType: item.directory ? 2 : (item.video ? 0 : 1),
        fileCount: item.vidQty,
        userId: widget.userId,
        platform: widget.platform,
        recommend: widget.recommend,
      );
      if (videoM.fileType != 2) {
        var result = _dbDatabase
            .where((mod) => mod.movieId == videoM.movieId)
            .toList();
        if (result.isEmpty) {
          AppDataBase.instance.addVideoModel(videoM);
        }
      }
      lists.add(videoM);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: Padding(
            padding: EdgeInsets.only(top: 12),
            child: _contentView(),
          ),
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
      title: Text(widget.name, textAlign: TextAlign.center),
      titleTextStyle: const TextStyle(
        letterSpacing: -0.5,
        fontSize: 16,
        color: Color(0xFF03011A),
      ),
    );
  }

  Widget _contentView() {
    return RefreshConfiguration(
      hideFooterWhenNotFull: true,
      child: RefreshPage(
        controller: _refreshController,
        itemNum: 1,
        onLoading: requestNetworkData,
        child: ListView.builder(
          itemCount: lists.length,
          itemBuilder: (context, index) {
            VideoModel data = lists[index];
            data.recommend = widget.recommend;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                openNextPage(data, lists);
              },
              child: IndexCell(model: data),
            );
          },
        ),
      ),
    );
  }

  void openNextPage(VideoModel data, List<VideoModel> list) async {
    switch (data.fileType) {
      case 0:
        PlayManager.pushPage(data, list, true);
      case 1:
        Get.to(() => ImagePage(data: data));
      case 2:
        Get.to(
          () => FileListPage(
            userId: data.userId,
            folderId: data.movieId,
            name: data.name,
            recommend: data.recommend,
            platform: data.platform,
            linkId: widget.linkId,
          ),
          preventDuplicates: false,
        );
    }
  }
}
