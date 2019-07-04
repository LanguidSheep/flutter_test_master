import 'package:flutter/material.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';

import 'network_cache_image.dart';

/// cgq_user_icon_widget
/// Created by Chen_Mr on 2019/6/27.

class CGQUserIconWidget extends StatelessWidget {
  final String image;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  CGQUserIconWidget(
      {this.image,
      this.onPressed,
      this.width = 30.0,
      this.height = 30.0,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding:
          padding ?? const EdgeInsets.only(top: 4.0, right: 5.0, left: 5.0),
      constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
      child: new ClipOval(
        child: FadeInImage(
          placeholder: AssetImage(CGQIConsConstant.DEFAULT_USER_ICON),
          image: new NetworkCacheImage(image),
          fit: BoxFit.fitWidth,
          width: width,
          height: height,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
