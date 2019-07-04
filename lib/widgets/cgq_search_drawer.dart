import 'package:flutter/material.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';

/// cgq_search_drawer : 搜索Drawer
/// Created by Chen_Mr on 2019/6/27.

typedef void SearchSelectItemChanged<String>(String value);

class CGQSearchDrawer extends StatefulWidget {
  final SearchSelectItemChanged<String> typeCallback;
  final SearchSelectItemChanged<String> sortCallback;
  final SearchSelectItemChanged<String> languageCallback;

  CGQSearchDrawer(this.typeCallback, this.sortCallback, this.languageCallback);

  @override
  State<StatefulWidget> createState() {
    return _GSYSearchDrawerState();
  }
}

class _GSYSearchDrawerState extends State<CGQSearchDrawer> {
  final double itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(top: CommonUtils.sStaticBarHeight),
      child: new Container(
        color: Color(CGQColorsConstant.white),
        child: new SingleChildScrollView(
          child: new Column(
            children: _renderList(),
          ),
        ),
      ),
    );
  }

  /// 创建备选列表
  _renderList() {
    List<Widget> list = new List();
    list.add(new Container(
      width: itemWidth,
    ));
    list.add(_renderTitle(CommonUtils.getLocale(context).search_type));
    for (int i = 0; i < searchFilterType.length; i++) {
      FilterModel model = searchFilterType[i];
      list.add(_renderItem(model, searchFilterType, i, widget.typeCallback));
      list.add(_renderDivider());
    }
    list.add(_renderTitle(CommonUtils.getLocale(context).search_type));
  }

  /// 列表标题
  _renderTitle(String title) {
    return new Container(
      color: Theme.of(context).primaryColor,
      width: itemWidth + 50,
      height: 50.0,
      child: new Center(
        child: new Text(
          title,
          style: CGQTextsConstant.middleTextWhite,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  /// 创建分割线
  _renderDivider() {
    return new Container(
      color: Color(CGQColorsConstant.subTextColor),
      width: itemWidth,
      height: 0.3,
    );
  }

  /// 创建列表内容
  _renderItem(FilterModel model, List<FilterModel> list, int index,
      SearchSelectItemChanged<String> select) {
    return new Stack(
      children: <Widget>[
        new Container(
          height: 50.0,
          child: new Container(
            width: itemWidth,
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Center(
                    child: new Checkbox(
                        value: model.select, onChanged: (value) {})),
                new Center(
                  child: new Text(model.name),
                )
              ],
            ),
          ),
        ),
        new FlatButton(
            onPressed: () {
              setState(() {
                for (FilterModel model in list) {
                  model.select = false;
                }
                list[index].select = true;
              });
              select?.call(model.value);
            },
            child: new Container(
              width: itemWidth,
            ))
      ],
    );
  }
}

class FilterModel {
  String name;
  String value;
  bool select;

  FilterModel({this.name, this.value, this.select});
}

var sortType = [
  FilterModel(name: 'desc', value: 'desc', select: true),
  FilterModel(name: 'asc', value: 'asc', select: false),
];
var searchFilterType = [
  FilterModel(name: "best_match", value: 'best%20match', select: true),
  FilterModel(name: "stars", value: 'stars', select: false),
  FilterModel(name: "forks", value: 'forks', select: false),
  FilterModel(name: "updated", value: 'updated', select: false),
];
var searchLanguageType = [
  FilterModel(name: "trendAll", value: null, select: true),
  FilterModel(name: "Java", value: 'Java', select: false),
  FilterModel(name: "Dart", value: 'Dart', select: false),
  FilterModel(name: "Objective_C", value: 'Objective-C', select: false),
  FilterModel(name: "Swift", value: 'Swift', select: false),
  FilterModel(name: "JavaScript", value: 'JavaScript', select: false),
  FilterModel(name: "PHP", value: 'PHP', select: false),
  FilterModel(name: "C__", value: 'C++', select: false),
  FilterModel(name: "C", value: 'C', select: false),
  FilterModel(name: "HTML", value: 'HTML', select: false),
  FilterModel(name: "CSS", value: 'CSS', select: false),
];
