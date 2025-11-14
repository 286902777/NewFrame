import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../generated/assets.dart';
import '../model/videoModel.dart';
import '../source/AppBasePage.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.data});
  final VideoModel data;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: CachedNetworkImage(
            imageUrl: widget.data.thumbnail,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(),
            errorWidget: (context, url, error) => Container(),
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
      title: Text(widget.data.name, textAlign: TextAlign.center),
      titleTextStyle: const TextStyle(
        letterSpacing: -0.5,
        fontSize: 16,
        color: Color(0xFF03011A),
      ),
    );
  }
}
