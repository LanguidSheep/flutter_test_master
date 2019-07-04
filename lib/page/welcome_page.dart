import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test_master/common/redux/cgq_state.dart';
import 'package:flutter_test_master/dao/user_dao.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/utils/flare/flutter/flare_actor.dart';
import 'package:flutter_test_master/utils/navigator_utils.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

/// welcome_page : 欢迎页
/// Created by Chen_Mr on 2019/6/18.

class WelcomePage extends StatefulWidget {
  static final String sName = "/";

  @override
  State<StatefulWidget> createState() {
    return _WelcomePageState();
  }
}

class _WelcomePageState extends State<WelcomePage> {
  bool hadInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hadInit) {
      return;
    }
    hadInit = true;

    /// 防止多次进入
    Store<CGQState> store = StoreProvider.of(context);
    CommonUtils.initStatusBarHeight(context);

    /// 延时等待
    new Future.delayed(const Duration(seconds: 3, microseconds: 500), () {
      /// 获取用户信息
      UserDao.initUserInfo(store).then((res) {
        /// 判断是否登录成功过
        if (res != null && res.result) {
          /// 进入主页
          NavigatorUtils.goHome(context);
        } else {
          /// 进入登录页
          NavigatorUtils.goLogin(context);
        }
        return true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<CGQState>(
      builder: (context, store) {
        double size = 200;
        return new Container(
          color: Color(CGQColorsConstant.white),
          child: Stack(
            children: <Widget>[
              /// 欢迎页背景图
              new Center(
                child: new Image(
                    image: new AssetImage('static/images/welcome.png')),
              ),

              /// 底部欢迎动画
              new Align(
                alignment: Alignment.bottomCenter,
                child: new Container(
                  width: size,
                  height: size,
                  child: new FlareActor("static/file/flare_flutter_logo_.flr",
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fill,
                      animation: "Placeholder"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
