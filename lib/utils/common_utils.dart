import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_statusbar/flutter_statusbar.dart';
import 'package:flutter_test_master/common/localization/cgq_string_base.dart';
import 'package:flutter_test_master/common/localization/default_localizations.dart';
import 'package:flutter_test_master/common/net/address.dart';
import 'package:flutter_test_master/common/redux/cgq_state.dart';
import 'package:flutter_test_master/common/redux/locale_redux.dart';
import 'package:flutter_test_master/common/redux/theme_redux.dart';
import 'package:flutter_test_master/widgets/cgq_flex_button.dart';
import 'package:flutter_test_master/widgets/issue_edit_dIalog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cgq_style.dart';
import 'navigator_utils.dart';
import 'package:redux/redux.dart';

/// common_utils
/// Created by Chen_Mr on 2019/6/17.

class CommonUtils {

  static final double MILLIS_LIMIT = 1000.0;

  static final double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static final double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static final double HOURS_LIMIT = 24 * MINUTES_LIMIT;

  static final double DAYS_LIMIT = 30 * HOURS_LIMIT;

  static double sStaticBarHeight = 0.0;

  static void initStatusBarHeight(context) async {
    sStaticBarHeight =
        await FlutterStatusbar.height / MediaQuery.of(context).devicePixelRatio;
  }

  ///日期格式转换
  static String getNewsTimeStr(DateTime date) {
    int subTime =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (subTime < MILLIS_LIMIT) {
      return "刚刚";
    } else if (subTime < SECONDS_LIMIT) {
      return (subTime / MILLIS_LIMIT).round().toString() + " 秒前";
    } else if (subTime < MINUTES_LIMIT) {
      return (subTime / SECONDS_LIMIT).round().toString() + " 分钟前";
    } else if (subTime < HOURS_LIMIT) {
      return (subTime / MINUTES_LIMIT).round().toString() + " 小时前";
    } else if (subTime < DAYS_LIMIT) {
      return (subTime / HOURS_LIMIT).round().toString() + " 天前";
    } else {
      return getDateStr(date);
    }
  }

  static getLocalPath() async {
    Directory appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getExternalStorageDirectory();
    }
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    String appDocPath = appDir.path + "/gsygithubappflutter";
    Directory appPath = Directory(appDocPath);
    await appPath.create(recursive: true);
    return appPath;
  }

  static String getDateStr(DateTime date) {
    if (date == null || date.toString() == null) {
      return "";
    } else if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 10);
  }

  static String getUserChartAddress(String userName) {
    return Address.graphicHost +
        CGQColorsConstant.primaryValueString.replaceAll("#", "") +
        "/" +
        userName;
  }

  /// 传入颜色 生成主题 ThemeData
  static getThemeData(Color color) {
    return ThemeData(primarySwatch: color, platform: TargetPlatform.android);
  }

  /// 获取国际化语言列表
  static CGQStringBase getLocale(BuildContext context) {
    return CGQLocalizations.of(context).currentLocalized;
  }

  /// 传入新的主题
  static pushTheme(Store store, int index) {
    ThemeData themeData;
    List<Color> colors = getThemeListColor();
    themeData = getThemeData(colors[index]);
    store.dispatch(new RefreshThemeDataAction(themeData));
  }

  static changeLocale(Store<CGQState> store,int index){
    Locale locale = store.state.platformLocale;
    switch(index){
      case 1:
        locale = Locale("zh","CH");
        break;
      case 2:
        locale = Locale("en","US");
        break;
    }
    store.dispatch(new RefreshLocaleAction(locale));
  }

  static saveImage(String url) async {
    Future<String> _findPath(String imageUrl) async {
      final file = await DefaultCacheManager().getSingleFile(url);
      if (file == null) {
        return null;
      }
      Directory localPath = await CommonUtils.getLocalPath();
      if (localPath == null) {
        return null;
      }
      final name = splitFileNameByPath(file.path);
      final result = await file.copy(localPath.path + name);
      return result.path;
    }

    return _findPath(url);
  }

  static splitFileNameByPath(String path) {
    return path.substring(path.lastIndexOf("/"));
  }

  /// 可切换的主题颜色列表
  static List<Color> getThemeListColor() {
    return [
      CGQColorsConstant.primarySwatch,
      Colors.brown,
      Colors.blue,
      Colors.teal,
      Colors.amber,
      Colors.blueGrey,
      Colors.deepOrange,
    ];
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  static isImageEnd(path) {
    bool image = false;
    for (String item in IMAGE_END) {
      if (path.indexOf(item) + item.length == path.length) {
        image = true;
      }
    }
    return image;
  }

  static copy(String data, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: data));
    Fluttertoast.showToast(
        msg: CommonUtils.getLocale(context).option_share_copy_success);
  }

  static void launchWebView(BuildContext context, String title, String url) {
    if (url.startsWith("http")) {
      NavigatorUtils.goGSYWebView(context, url, title);
    } else {
      NavigatorUtils.goGSYWebView(
          context,
          new Uri.dataFromString(url,
              mimeType: 'text/html', encoding: Encoding.getByName("utf-8"))
              .toString(),
          title);
    }
  }

  static launchOutURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: CommonUtils.getLocale(context).option_web_launcher_error +
              ": " +
              url);
    }
  }

  static Future<Null> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showCGQDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => new Future.value(false),
                child: Center(
                  child: new Container(
                    width: 200.0,
                    height: 200.0,
                    padding: new EdgeInsets.all(4.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                            child: SpinKitCubeGrid(
                                color: Color(CGQColorsConstant.white))),
                        new Container(height: 10.0),
                        new Container(
                            child: new Text(
                                CommonUtils.getLocale(context).loading_text,
                                style: CGQTextsConstant.normalTextWhite)),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  static Future<Null> showEditDialog(
    BuildContext context,
    String dialogTitle,
    ValueChanged<String> onTitleChanged,
    ValueChanged<String> onContentChanged,
    VoidCallback onPressed, {
    TextEditingController titleController,
    TextEditingController valueController,
    bool needTitle = true,
  }) {
    return NavigatorUtils.showCGQDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: new IssueEditDialog(
              dialogTitle,
              onTitleChanged,
              onContentChanged,
              onPressed,
              titleController: titleController,
              valueController: valueController,
              needTitle: needTitle,
            ),
          );
        });
  }

  ///列表item dialog
  static Future<Null> showCommitOptionDialog(
    BuildContext context,
    List<String> commitMaps,
    ValueChanged<int> onTap, {
    width = 250.0,
    height = 400.0,
    List<Color> colorList,
  }) {
    return NavigatorUtils.showCGQDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: new Container(
              width: width,
              height: height,
              padding: new EdgeInsets.all(4.0),
              margin: new EdgeInsets.all(20.0),
              decoration: new BoxDecoration(
                color: Color(CGQColorsConstant.white),
                //用一个BoxDecoration装饰器提供背景图片
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: new ListView.builder(
                  itemCount: commitMaps.length,
                  itemBuilder: (context, index) {
                    return CGQFlexButton(
                      maxLines: 1,
                      mainAxisAlignment: MainAxisAlignment.start,
                      fontSize: 14.0,
                      color: colorList != null
                          ? colorList[index]
                          : Theme.of(context).primaryColor,
                      text: commitMaps[index],
                      textColor: Color(CGQColorsConstant.white),
                      onPress: () {
                        Navigator.pop(context);
                        onTap(index);
                      },
                    );
                  }),
            ),
          );
        });
  }

  ///版本更新
  static Future<Null> showUpdateDialog(
      BuildContext context, String contentMsg) {
    return NavigatorUtils.showCGQDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(CommonUtils.getLocale(context).app_version_title),
            content: new Text(contentMsg),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text(CommonUtils.getLocale(context).app_cancel)),
              new FlatButton(
                  onPressed: () {
                    launch(Address.updateUrl);
                    Navigator.pop(context);
                  },
                  child: new Text(CommonUtils.getLocale(context).app_ok)),
            ],
          );
        });
  }
}
