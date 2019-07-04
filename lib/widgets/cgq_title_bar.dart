import 'package:flutter/material.dart';

/// cgq_title_bar
/// Created by Chen_Mr on 2019/6/25.

class CGQTitleBar extends StatelessWidget {
  final String title;

  final IconData iconData;

  final VoidCallback onPressed;

  final bool needRightLocalIcon;

  final Widget rightWidget;

  CGQTitleBar({
    this.title,
    this.iconData,
    this.onPressed,
    this.rightWidget,
    this.needRightLocalIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = rightWidget;
    if (rightWidget == null) {
      widget = (needRightLocalIcon)
          ? new IconButton(
              icon: new Icon(
                iconData,
                size: 19.0,
              ),
              onPressed: onPressed)
          : new Container();
    }
    return Container(
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          widget
        ],
      ),
    );
  }
}
