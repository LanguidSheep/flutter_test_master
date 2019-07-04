import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_master/common/localization/default_localizations.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/utils/navigator_utils.dart';
import 'package:flutter_test_master/widgets/CGQTabBarWidget.dart';
import 'package:flutter_test_master/widgets/cgq_title_bar.dart';
import 'package:flutter_test_master/widgets/home_drawer.dart';

import 'dynamic_page.dart';
import 'my_page.dart';
import 'trend_page.dart';

/// home_page:主页
/// Created by Chen_Mr on 2019/6/18.

class HomePage extends StatelessWidget {
  static final String sName = "home";

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    /// 如果是 Android 回到桌面
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.HOME');
      await intent.launch();
    }
    return Future.value(false);
  }

  _renderTab(icon, text) {
    return new Tab(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Icon(icon, size: 16.0), new Text(text)],
      ),
    );
  }

  /// 这里是整个应用程序的最根级
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(CGQIConsConstant.MAIN_DT,
          CommonUtils.getLocale(context).home_dynamic),
      _renderTab(CGQIConsConstant.MAIN_QS,
          CommonUtils.getLocale(context).home_dynamic),
      _renderTab(CGQIConsConstant.MAIN_MY,
          CommonUtils.getLocale(context).home_dynamic),
    ];

    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: new CGQTabBarWidget(
        drawer: new HomeDrawer(),
        type: CGQTabBarWidget.BOTTOM_TAB,
        tabItems: tabs,
        tabViews: <Widget>[
          new DynamicPage(),
          new TrendPage(),
          new MyPage()
        ],
        backgroundColor: CGQColorsConstant.primarySwatch,
        indicatorColor: Color(CGQColorsConstant.white),
        title: CGQTitleBar(
          title: CGQLocalizations.of(context).currentLocalized.app_name,
          iconData: CGQIConsConstant.MAIN_SEARCH,
          needRightLocalIcon: true,
          onPressed: () {
            NavigatorUtils.goSearchPage(context);
          },
        ),
      ),
    );
  }
}
