import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserVipBasePage extends StatelessWidget {
  final Widget child;
  const UserVipBasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/svip/svip_bg.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        Positioned(child: child),
      ],
    );
  }
}
