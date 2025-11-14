import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshPage extends StatefulWidget {
  final bool enUseUpPull;
  final bool enUseDownPull;
  final RefreshController? controller;
  final int? itemNum;
  final Widget child;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final VoidCallback? onRetry;

  const RefreshPage({
    super.key,
    this.controller,
    this.itemNum = 0,
    this.enUseUpPull = true,
    this.enUseDownPull = false,
    this.onRefresh,
    this.onLoading,
    this.onRetry,
    required this.child,
  });

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  late int? _dataNum = widget.itemNum;
  late final RefreshController _controller =
      widget.controller ?? RefreshController();

  @override
  void didUpdateWidget(covariant RefreshPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _dataNum = widget.itemNum;
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      header: refreshHeader(),
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      enablePullUp: widget.enUseUpPull,
      enablePullDown: widget.enUseDownPull,
      child: _contentView(),
    );
  }

  Widget refreshHeader() {
    return WaterDropHeader(
      waterDropColor: Colors.transparent,
      refresh: const CupertinoActivityIndicator(color: Colors.grey, radius: 13),
      complete: Container(),
      completeDuration: const Duration(seconds: 0),
    );
  }

  Widget _contentView() {
    if (_dataNum == null) {
      return Container();
    }
    return widget.child;
  }
}
