import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBasePage extends StatelessWidget {
  final Widget child;
  const AppBasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/app_bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}
