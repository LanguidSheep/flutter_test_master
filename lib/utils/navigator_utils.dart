import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_master/page/cgq_webview.dart';
import 'package:flutter_test_master/page/common_list_page.dart';
import 'package:flutter_test_master/page/home_page.dart';
import 'package:flutter_test_master/page/login_page.dart';
import 'package:flutter_test_master/page/person_page.dart';
import 'package:flutter_test_master/page/photoview_page.dart';
import 'package:flutter_test_master/page/search_page.dart';

///  导航栏
class NavigatorUtils {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///主页
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomePage.sName);
  }

  ///登录页
  static goLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginPage.sName);
  }

  ///搜索
  static Future goSearchPage(BuildContext context) {
    return navigatorRouter(context, new SearchPage());
  }

  ///个人中心
  static goPerson(BuildContext context, String userName) {
    navigatorRouter(context, new PersonPage(userName));
  }

  ///仓库详情
  static Future goReposDetail(
      BuildContext context, String userName, String reposName) {
    // TODO 跳转仓库详情
  }

  ///仓库详情通知
  static Future goNotifyPage(BuildContext context) {
    // TODO 仓库详情通知页面
  }

  ///用户配置
  static gotoUserProfileInfo(BuildContext context) {
    // TODO 跳转用户配置界面
  }

  ///通用列表
  static gotoCommonList(
      BuildContext context, String title, String showType, String dataType,
      {String userName, String reposName}) {
    navigatorRouter(
        context,
        new CommonListPage(
          title,
          showType,
          dataType,
          userName: userName,
          reposName: reposName,
        ));
  }

  ///提交详情
  static Future goPushDetailPage(BuildContext context, String userName,
      String reposName, String sha, bool needHomeIcon) {
    // TODO 提交详情页面
  }

  ///全屏Web页面
  static Future goGSYWebView(BuildContext context, String url, String title) {
    return navigatorRouter(context, new CGQWebView(url, title));
  }

  ///issue详情
  static Future goIssueDetail(
      BuildContext context, String userName, String reposName, String num,
      {bool needRightLocalIcon = false}) {
    // TODO issue详情页面
  }

  ///图片预览
  static gotoPhotoViewPage(BuildContext context, String url) {
    navigatorRouter(context, new PhotoViewPage(url));
  }

  ///公共打开方式
  static navigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context,
        new CupertinoPageRoute(builder: (context) => pageContainer(widget)));
  }

  ///Page页面的容器，做一次通用自定义
  static Widget pageContainer(widget) {
    return MediaQuery(

        ///不受系统字体缩放影响
        data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .copyWith(textScaleFactor: 1),
        child: widget);
  }

  ///弹出 dialog
  static Future<T> showCGQDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .copyWith(textScaleFactor: 1),
              child: new SafeArea(child: builder(context)));
        });
  }
}
