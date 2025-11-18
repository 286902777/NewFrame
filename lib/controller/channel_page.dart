import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:frame/admob_max/admob_max_tool.dart';
import 'package:frame/event/back_event_manager.dart';
import 'package:frame/source/AppDataManager.dart';
import 'package:frame/source/app_key.dart';
import 'package:frame/view/index_cell.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../admob_max/native_page.dart';
import '../event/event_manager.dart';
import '../event/http_manager.dart';
import '../generated/assets.dart';
import '../model/indexModel.dart';
import '../model/videoModel.dart';
import '../source/Common.dart';
import '../source/CusToast.dart';
import '../source/RefreshPage.dart';
import '../source/play_manager.dart';
import 'file_list_page.dart';
import 'image_page.dart';

enum StationLabel {
  video(0, 'All videos'),
  hot(1, 'Hot'),
  recently(2, 'Recently');

  final int idx;
  final String value;
  const StationLabel(this.idx, this.value);
}

class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key, required this.userId, required this.platform});

  final String userId;
  final PlatformType platform;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage>
    with AutomaticKeepAliveClientMixin, RouteAware {
  var selectIndex = 0.obs;
  final PageController _controller = PageController();
  final RefreshController _refreshController = RefreshController();

  User? user;
  int page = 1;
  int randomPage = 1;
  int pageSize = 20;
  String? randomUserId;
  bool loadRecommend = false;

  List<VideoModel> allArray = [];
  List<VideoModel> hotArray = [];
  List<VideoModel> newArray = [];

  var otherChange = false.obs;
  var userInfoChange = false.obs;
  bool noMoreData = false;
  final List<StationLabel> lists = [
    StationLabel.video,
    StationLabel.hot,
    StationLabel.recently,
  ];

  bool isCurrentPage = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventSource = BackEventSource.channelPage;
    eventAdsSource = AdmobSource.channelpage;
    EventManager.instance.enventUpload(EventApi.channelpageExpose, {
      'GSjzKapRnA': channelSource.name,
    });
    requestData();
    AdmobMaxTool.showAdsScreen(AdsSceneType.channel);
    AdmobMaxTool.addListener(hashCode.toString(), (
      state, {
      adsType,
      ad,
      sceneType,
    }) async {
      if (isCurrentPage == false) {
        return;
      }
      if (state == AdsState.showing &&
          AdmobMaxTool.scene == AdsSceneType.channel) {
        String linkId = await AppKey.getString(AppKey.appLinkId) ?? '';
        BackEventManager.instance.getAdsValue(
          BackEventName.advProfit,
          widget.platform,
          ad,
          linkId,
          '',
          '',
        );
        if (adsType == AdsType.native) {
          Get.to(
            () => NativePage(
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.channel,
            ),
          )?.then((result) {
            AdmobMaxTool.instance.nativeDismiss(
              AdsState.dismissed,
              adsType: AdsType.native,
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.channel,
            );
          });
        }
      }
      if (state == AdsState.dismissed &&
          AdmobMaxTool.scene == AdsSceneType.channel) {
        if (sceneType == AdsSceneType.plus || adsType == AdsType.rewarded) {
          // subscriberSource = SubscriberSource.ad;
          // PlayerManager.showResult(true);
        } else {
          displayPlusAds();
        }
      }
    });
  }

  void displayPlusAds() async {
    // bool suc = await AdmobMaxTool.showAdsScreen(AdsSceneType.plus);
    // if (suc == false) {
    //   subscriberSource = SubscriberSource.ad;
    //   PlayManager.showResult(true);
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    EasyLoading.dismiss();
    // AdmobMaxTool.removeListener(hashCode.toString());
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didPopNext() {
    isCurrentPage = true;
    super.didPopNext();
  }

  @override
  void didPush() {
    isCurrentPage = true;
    super.didPush();
  }

  @override
  void didPushNext() {
    isCurrentPage = false;
    super.didPushNext();
  }

  Future requestData() async {
    // uid: spasmodist channel_id:// varanger  link_id:// /pm57gqcgxs/norselled  version:// gangways
    if (loadRecommend) {
      requestRecommendData();
    } else {
      if (noMoreData) {
        _refreshController.loadNoData();
        return;
      }
      await HttpManager.postRequest(
        ApiKey.home,
        widget.platform,
        para: {
          'nitering': page,
          'prereport': pageSize,
          'watchfire': widget.userId,
          'typewrite': {'alevin': ''},
          'pterylosis': 'v2',
        },
        successHandle: (data) async {
          if (data != null) {
            IndexModel model = indexModelFromJson(data);
            if (model.user != null && model.user!.id.isNotEmpty && page == 1) {
              user = model.user;
              userInfoChange.value = true;
              AppdataManager.instance.updateUser(
                model.user?.id ?? '',
                widget.platform == PlatformType.india ? 0 : 1,
                jsonEncode(model.user!.toJson()),
              );
            }
            if (model.files.length < pageSize) {
              if (model.files.length < 5 && page == 1) {
                randomUserId = user?.id;
                loadRecommend = true;
                requestRecommendData();
              } else {
                await _requestUserListInfo(user?.id ?? '');
              }
            }
            if (model.files.isNotEmpty) {
              replaceModel(model);
              page = page + 1;
            }
          }
          _refreshController.loadComplete();
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            requestData();
          } else {
            _refreshController.loadFailed();
            CusToast.show(message: msg, type: CusToastType.fail);
          }
        },
      );
    }
  }

  void replaceModel(IndexModel model) {
    if (model.files.isNotEmpty) {
      for (IndexListModel item in model.files) {
        VideoModel videoM = VideoModel(
          name: item.disPlayName.carrow,
          movieId: item.id,
          size: Common.instance.countFile(item.fileMeta.size),
          ext: item.fileMeta.extension,
          netMovie: 1,
          createDate: item.updateTime,
          thumbnail: item.fileMeta.thumbnail,
          fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
          fileCount: item.vidQty,
          userId: user?.id ?? '',
          platform: widget.platform == PlatformType.india ? 0 : 1,
        );
        allArray.add(videoM);
      }
      if (mounted) {
        setState(() {});
      }
    }
    if (page == 1) {
      for (IndexListModel item in model.top) {
        VideoModel videoM = VideoModel(
          name: item.disPlayName.carrow,
          movieId: item.id,
          size: Common.instance.countFile(item.fileMeta.size),
          ext: item.fileMeta.extension,
          netMovie: 1,
          createDate: item.updateTime,
          thumbnail: item.fileMeta.thumbnail,
          fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
          fileCount: item.vidQty,
          userId: user?.id ?? '',
          platform: widget.platform == PlatformType.india ? 0 : 1,
        );
        hotArray.add(videoM);
      }
      for (IndexListModel item in model.recent) {
        VideoModel videoM = VideoModel(
          name: item.disPlayName.carrow,
          movieId: item.id,
          size: Common.instance.countFile(item.fileMeta.size),
          ext: item.fileMeta.extension,
          netMovie: 1,
          createDate: item.updateTime,
          thumbnail: item.fileMeta.thumbnail,
          fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
          fileCount: item.vidQty,
          userId: user?.id ?? '',
          platform: widget.platform == PlatformType.india ? 0 : 1,
        );
        newArray.add(videoM);
      }
      otherChange.value = true;
    }
  }

  Future<void> _requestUserListInfo(String uId) async {
    await AppdataManager.instance.getPlatformUser(
      widget.platform == PlatformType.india ? 0 : 1,
    );
    List<UserPools> users = AppDataBase.instance.users;
    List<Map<String, dynamic>> labelArr = [];
    users.forEach((mod) {
      mod.labels.forEach((label) {
        Map<String, dynamic> dic = {
          'angered': label.id,
          'coachable': label.labelName,
          'paradisian': label.firstLabelCode,
          'shunts': label.secondLabelCode,
        };
        labelArr.add(dic);
      });
    });
    await HttpManager.postRequest(
      ApiKey.userPools,
      widget.platform,
      para: {
        'faquir': {'thermopile': labelArr},
        'insinking': Platform.isIOS ? 'ios' : 'android',
        'cipherable': uId,
      },
      successHandle: (data) {
        if (data != null && data is List) {
          Random random = Random();
          int randomIdx = random.nextInt(data.length);
          if (randomIdx < data.length) {
            randomUserId = data[randomIdx]['cipherable'];
          } else {
            randomUserId = data.first['cipherable'];
          }
          loadRecommend = true;
          requestRecommendData();
        }
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          _requestUserListInfo(uId);
        }
      },
    );
  }

  Future requestRecommendData() async {
    await HttpManager.recommendPostRequest(
      ApiKey.home,
      widget.platform,
      randomPage > 1,
      para: {
        'nitering': page,
        'prereport': pageSize,
        'watchfire': randomUserId,
        'typewrite': {'alevin': ''},
        'pterylosis': 'v2',
      },
      successHandle: (data) {
        EasyLoading.dismiss();
        if (data != null) {
          IndexModel model = indexModelFromJson(data);
          if (model.files.isNotEmpty) {
            if (randomPage == 1) {
              allArray.add(VideoModel(name: 'Recommend'));
            }
            for (IndexListModel item in model.files) {
              VideoModel videoM = VideoModel(
                name: item.disPlayName.carrow,
                linkId: '',
                movieId: item.id,
                size: Common.instance.countFile(item.fileMeta.size),
                ext: item.fileMeta.extension,
                netMovie: 1,
                createDate: item.updateTime,
                thumbnail: item.fileMeta.thumbnail,
                recommend: 1,
                fileType: item.directory ? 2 : (item.video ? 0 : 1),
                fileCount: item.vidQty,
                userId: randomUserId ?? '',
                platform: widget.platform == PlatformType.india ? 0 : 1,
              );
              allArray.add(videoM);
            }
            setState(() {});
            randomPage = randomPage + 1;
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
            noMoreData = true;
          }
        }
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          requestRecommendData();
        } else {
          _refreshController.loadFailed();
          CusToast.show(message: msg, type: CusToastType.fail);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: Get.width / 375 * 230,
            child: CachedNetworkImage(
              imageUrl: userInfoChange.value ? user?.picture ?? '' : '',
              fit: BoxFit.cover,
              height: Get.width / 375 * 230,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBCDAFF), Color(0xFF5E9EFF)], // 中心到边缘颜色
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBCDAFF), Color(0xFF5E9EFF)], // 中心到边缘颜色
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Color(0xFFD8D8D8)),
          ),
        ),
        // Positioned(
        //   top: 0,
        //   left: 0,
        //   right: 0,
        //   child: Container(
        //     height: Get.width / 375 * 230,
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [Color(0xFFBCDAFF), Color(0xFF5E9EFF)], // 中心到边缘颜色
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //       ),
        //     ),
        //   ),
        // ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: headerView(),
        ),
      ],
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
            child: Image.asset(Assets.assetsChannelBack, width: 24),
          ),
        ],
      ),
      // actions: [
      //   GestureDetector(
      //     onTap: () {
      //       subscriberMethod = SubscriberMethod.click;
      //       subscriberSource = SubscriberSource.channelPage;
      //       Get.to(() => MyUserPage());
      //     },
      //     child: Image.asset(Assets.userVipNavBtn, width: 64, height: 28),
      //   ),
      //   SizedBox(width: 12),
      // ],
    );
  }

  Widget headerView() {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 66,
            child: Stack(
              fit: StackFit.loose,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      Assets.assetsChannelVatar,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: (Get.width - 56) * 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    child: CachedNetworkImage(
                      imageUrl: userInfoChange.value ? user?.picture ?? '' : '',
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      placeholder: (context, url) =>
                          Container(color: Colors.transparent),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
          Text(
            userInfoChange.value ? user?.name ?? '' : '',
            style: const TextStyle(
              letterSpacing: -0.5,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          SizedBox(height: 16),
          Expanded(child: Container(child: contentView())),
        ],
      ),
    );
  }

  Widget contentView() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFFF5FAF9), Color(0xFFF9F9F9)], // 中心到边缘颜色
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 72,
            padding: EdgeInsets.only(left: 12),
            child: Obx(
              () => Wrap(
                direction: Axis.horizontal,
                spacing: 28,
                children: List.generate(
                  lists.length,
                  (index) => GestureDetector(
                    onTap: () {
                      selectIndex.value = lists[index].idx;
                      _controller.jumpToPage(index);
                    },
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              image: selectIndex.value == index
                                  ? DecorationImage(
                                      image: AssetImage(Assets.assetsSegBg),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: Text(
                              lists[index].value,
                              style: TextStyle(
                                letterSpacing: -0.5,
                                fontSize: selectIndex.value == index ? 12 : 14,
                                fontWeight: FontWeight.w500,
                                color: selectIndex.value == index
                                    ? Color(0xFFFFFFFF)
                                    : Color(0xFF4C4C4C),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          if (selectIndex.value == index)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                                color: Color(0xFF0C0C0C),
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  allContentView(),
                  hotContentView(),
                  newContentView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget allContentView() {
    return RefreshConfiguration(
      hideFooterWhenNotFull: true,
      child: RefreshPage(
        controller: _refreshController,
        itemNum: 1,
        onLoading: requestData,
        child: ListView.builder(
          itemCount: allArray.length,
          itemBuilder: (context, index) {
            if (allArray[index].name == 'Recommend' &&
                allArray[index].movieId.isEmpty) {
              return _recommendTitleView();
            } else {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  playSource = PlaySource.channel_file;
                  openPlayPage(allArray[index], allArray);
                },
                child: IndexCell(model: allArray[index]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _recommendTitleView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (randomUserId != null) {
          Get.to(
            () => ChannelPage(userId: randomUserId!, platform: widget.platform),
            preventDuplicates: false,
          );
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recommend',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121212),
              ),
            ),
            Spacer(),
            Text(
              'More',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF919191),
              ),
            ),
            SizedBox(width: 4),
            Image.asset(Assets.assetsArrow, width: 12, height: 12),
          ],
        ),
      ),
    );
  }

  Widget hotContentView() {
    return Obx(
      () => ListView.builder(
        itemCount: otherChange.value ? hotArray.length : 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              playSource = PlaySource.channel_hot;
              openPlayPage(hotArray[index], hotArray);
            },
            child: IndexCell(model: hotArray[index], isHot: true),
          );
        },
      ),
    );
  }

  Widget newContentView() {
    return Obx(
      () => ListView.builder(
        itemCount: otherChange.value ? newArray.length : 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              playSource = PlaySource.channel_recently;
              openPlayPage(newArray[index], newArray);
            },
            child: IndexCell(model: newArray[index]),
          );
        },
      ),
    );
  }

  void openPlayPage(VideoModel data, List<VideoModel> list) async {
    switch (data.fileType) {
      case 0:
        if (data.recommend == 1) {
          playSource = PlaySource.channel_recommend;
        }
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
            linkId: '',
          ),
        );
    }
  }
}
