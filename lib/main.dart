import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test_master/page/login_page.dart';
import 'package:flutter_test_master/page/welcome_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'common/event/http_error_event.dart';
import 'common/event/index.dart';
import 'common/localization/cgq_localizations_delegate.dart';
import 'common/net/code.dart';
import 'common/redux/cgq_state.dart';
import 'entity/User.dart';
import 'page/home_page.dart';
import 'utils/cgq_style.dart';
import 'utils/common_utils.dart';
import 'utils/navigator_utils.dart';

void main() {
  runZoned(() {
    runApp(FlutterReduxApp());

    /// 设置图片缓存的个数
    PaintingBinding.instance.imageCache.maximumSize = 100;
  }, onError: (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });
}

class FlutterReduxApp extends StatelessWidget {
  /// 用来保存全局的用户信息、主题样式和国际化语言设置
  final store = new Store<CGQState>(appReducer,
      middleware: middleware,
      initialState: new CGQState(

          /// 一个空的用户保存
          userInfo: User.empty(),

          /// 创建主题，保存在store中
          themeData: CommonUtils.getThemeData(CGQColorsConstant.primarySwatch),

          /// 中文国际化语言
          locale: Locale('zh', 'CH')));

  FlutterReduxApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new StoreBuilder<CGQState>(builder: (context, store) {
        return new MaterialApp(
          /// 多语言实现代理
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            CGQLocalizationsDelegate.delegate
          ],
          /// 国际化语言设置< 在全局唯一的store中获取>
          locale: store.state.locale,
          supportedLocales: [store.state.locale],
          /// 主题设置< 在全局唯一的store中获取>
          theme: store.state.themeData,
          routes: {
            WelcomePage.sName: (context) {
              store.state.platformLocale = Localizations.localeOf(context);
              return WelcomePage();
            },
            HomePage.sName: (context) {
              ///通过Localizations.override包裹一层
              return new CGQLocalizations(
                child: NavigatorUtils.pageContainer(new HomePage()),
              );
            },
            LoginPage.sName: (context) {
              return new CGQLocalizations(
                child: NavigatorUtils.pageContainer(new LoginPage()),
              );
            }
          },
        );
      }),
    );
  }
}

class CGQLocalizations extends StatefulWidget {
  final Widget child;

  CGQLocalizations({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _CGQLocalizations();
  }
}

class _CGQLocalizations extends State<CGQLocalizations> {
  StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<CGQState>(builder: (context, store) {
      return new Localizations.override(
          context: context,
          locale: store.state.locale,
          child: widget.child);
    });
  }

  @override
  void initState() {
    super.initState();
    /// EventBus 消息接受
    stream = eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    /// 页面关闭，取消EventBus消息接受
    if (stream != null) {
      stream.cancel();
      stream = null;
    }
  }

  ///网络错误提醒
  errorHandleFunction(int code, message) {
    switch (code) {
      case Code.NETWORK_ERROR:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error);
        break;
      case 401:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_401);
        break;
      case 403:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_403);
        break;
      case 404:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_404);
        break;
      case Code.NETWORK_TIMEOUT:
        //超时
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_timeout);
        break;
      default:
        Fluttertoast.showToast(
            msg: CommonUtils.getLocale(context).network_error_unknown +
                " " +
                message);
        break;
    }
  }
}
