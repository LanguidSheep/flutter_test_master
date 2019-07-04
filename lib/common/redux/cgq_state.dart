import 'package:flutter/material.dart';
import 'package:flutter_test_master/entity/User.dart';

import 'locale_redux.dart';
import 'middleware/epic_middleware.dart';
import 'theme_redux.dart';
import 'user_redux.dart';
import 'package:redux/redux.dart';

/// cgq_state: Redux全局State
/// Created by Chen_Mr on 2019/6/17.

class CGQState {
  /// 用户信息
  User userInfo;

  /// 主题数据
  ThemeData themeData;

  /// 语言
  Locale locale;

  /// 当前手机默认语言
  Locale platformLocale;

  CGQState({this.userInfo, this.themeData, this.locale});
}

///创建 Reducer
///源码中 Reducer 是一个方法 typedef State Reducer<State>(State state, dynamic action);
///我们自定义了 appReducer 用于创建 store
CGQState appReducer(CGQState state, action) {
  return CGQState(
    ///通过 UserReducer 将 GSYState 内的 userInfo 和 action 关联在一起
    userInfo: UserReducer(state.userInfo, action),

    ///通过 ThemeDataReducer 将 GSYState 内的 themeData 和 action 关联在一起
    themeData: ThemeDataReducer(state.themeData, action),

    ///通过 LocaleReducer 将 GSYState 内的 locale 和 action 关联在一起
    locale: LocaleReducer(state.locale, action),
  );
}

final List<Middleware<CGQState>> middleware = [
  EpicMiddleware<CGQState>(UserInfoEpic()),
  UserInfoMiddleware(),
];
