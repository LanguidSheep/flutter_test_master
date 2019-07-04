import 'package:flutter/material.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';

import 'cgq_card_item.dart';

/// 详情issue列表头部，PreferredSizeWidget


typedef void SelectItemChanged<int>(int value);

class CGQSelectItemWidget extends StatefulWidget implements PreferredSizeWidget {
  final List<String> itemNames;

  final SelectItemChanged selectItemChanged;

  final RoundedRectangleBorder shape;

  final double elevation;

  final double height;

  final EdgeInsets margin;

  CGQSelectItemWidget(
    this.itemNames,
    this.selectItemChanged, {
    this.elevation = 5.0,
    this.height = 70.0,
    this.shape,
    this.margin = const EdgeInsets.all(10.0),
  });

  @override
  _CGQSelectItemWidgetState createState() => _CGQSelectItemWidgetState();

  @override
  Size get preferredSize {
    return new Size.fromHeight(height);
  }
}

class _CGQSelectItemWidgetState extends State<CGQSelectItemWidget> {
  int selectIndex = 0;

  _CGQSelectItemWidgetState();

  _renderItem(String name, int index) {
    var style = index == selectIndex ? CGQTextsConstant.middleTextWhite : CGQTextsConstant.middleSubLightText;
    return new Expanded(
      child: RawMaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
          padding: EdgeInsets.all(10.0),
          child: new Text(
            name,
            style: style,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            if (selectIndex != index) {
              widget.selectItemChanged?.call(index);
            }
            setState(() {
              selectIndex = index;
            });
          }),
    );
  }

  _renderList() {
    List<Widget> list = new List();
    for (int i = 0; i < widget.itemNames.length; i++) {
      if (i == widget.itemNames.length - 1) {
        list.add(_renderItem(widget.itemNames[i], i));
      } else {
        list.add(_renderItem(widget.itemNames[i], i));
        list.add(new Container(width: 1.0, height: 25.0, color: Color(CGQColorsConstant.subLightTextColor)));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new CGQCardItem(
        elevation: widget.elevation,
        margin: widget.margin,
        color: Theme.of(context).primaryColor,
        shape: widget.shape ?? new RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: new Row(
          children: _renderList(),
        ));
  }
}
