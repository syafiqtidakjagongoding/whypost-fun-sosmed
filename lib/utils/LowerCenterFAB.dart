import 'package:flutter/material.dart';

class LowerCenterFAB extends FloatingActionButtonLocation {
  final double offsetY; // seberapa turun
  const LowerCenterFAB({this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.minInsets.bottom -
        scaffoldGeometry.floatingActionButtonSize.height +
        offsetY; // 👉 angka positif = makin turun

    return Offset(fabX, fabY);
  }
}
