import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test_master/common/config.dart';
import 'package:flutter_test_master/common/db/sql_manager.dart';
import 'package:flutter_test_master/common/local/local_storage.dart';
import 'package:flutter_test_master/common/redux/cgq_state.dart';
import 'package:flutter_test_master/dao/ReposDao.dart';
import 'package:flutter_test_master/dao/issue_dao.dart';
import 'package:flutter_test_master/dao/user_dao.dart';
import 'package:flutter_test_master/entity/User.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/utils/navigator_utils.dart';
import 'package:package_info/package_info.dart';

import 'package:redux/redux.dart';

import 'cgq_flex_button.dart';

/// home_drawer：主页Drawer
/// Created by Chen_Mr on 2019/6/26.

class HomeDrawer extends StatelessWidget {
  showAboutDialog(BuildContext context, String versionName) {
    versionName ??= "Null";
    NavigatorUtils.showCGQDialog(
        context: context,
        builder: (BuildContext context) => AboutDialog(
              applicationName: CommonUtils.getLocale(context).app_name,
              applicationVersion: CommonUtils.getLocale(context).app_version +
                  ":" +
                  versionName,
              applicationIcon: new Image(
                image: new AssetImage(CGQIConsConstant.DEFAULT_USER_ICON),
                width: 50.0,
                height: 50.0,
              ),
              applicationLegalese: "http://github.com/LanguidSheep",
            ));
  }

  /// 显示切换主题弹出框
  showThemeDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_theme_default,
      CommonUtils.getLocale(context).home_theme_1,
      CommonUtils.getLocale(context).home_theme_2,
      CommonUtils.getLocale(context).home_theme_3,
      CommonUtils.getLocale(context).home_theme_4,
      CommonUtils.getLocale(context).home_theme_5,
      CommonUtils.getLocale(context).home_theme_6,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      /// 变更主题
      CommonUtils.pushTheme(store, index);

      /// 偏好文件保存一选择的主题颜色
      LocalStorage.save(Config.THEME_COLOR, index.toString());
    }, colorList: CommonUtils.getThemeListColor());
  }

  /// 显示切换语言弹出框
  showLanguageDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_language_default,
      CommonUtils.getLocale(context).home_language_zh,
      CommonUtils.getLocale(context).home_language_en,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      /// 改变国际化语言
      CommonUtils.changeLocale(store, index);

      /// 偏好文件持久化保存
      LocalStorage.save(Config.LOCALE, index.toString());
    }, height: 150.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: new StoreBuilder<CGQState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          return new Drawer(
            /// 侧边栏按钮 Drawer
            child: Container(
              /// 默认背景
              color: store.state.themeData.primaryColor,
              child: new SingleChildScrollView(
                /// item 背景
                child: new Container(
                  constraints: new BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height),
                  child: new Material(
                    color: Color(CGQColorsConstant.white),
                    child: new Column(
                      children: <Widget>[
                        /// 侧边栏头部布局
                        new UserAccountsDrawerHeader(
                          /// 用户名
                          accountName: new Text(
                            user.login ?? "--",
                            style: CGQTextsConstant.largeTextWhite,
                          ),

                          /// 用户邮箱
                          accountEmail: new Text(
                            user.email ?? user.name ?? "--",
                            style: CGQTextsConstant.normalTextLight,
                          ),

                          /// 用户头像
                          currentAccountPicture: new GestureDetector(
                            onTap: () {},
                            child: new CircleAvatar(
                              backgroundImage: new NetworkImage(
                                  user.avatar_url ??
                                      CGQIConsConstant.DEFAULT_REMOTE_PIC),
                            ),
                          ),

                          /// 用一个BoxDecoration装饰器提供背景图片
                          decoration: new BoxDecoration(
                            color: store.state.themeData.primaryColor,
                          ),
                        ),

                        /// 问题反馈Item
                        new ListTile(
                            title: new Text(
                              CommonUtils.getLocale(context).home_reply,
                              style: CGQTextsConstant.normalText,
                            ),
                            onTap: () {
                              String content = "";
                              CommonUtils.showEditDialog(
                                context,
                                CommonUtils.getLocale(context).home_reply,
                                (title) {},
                                (res) {
                                  content = res;
                                },
                                () {
                                  if (content == null || content.length == 0) {
                                    return;
                                  }
                                  CommonUtils.showLoadingDialog(context);
                                  IssueDao.createIssueDao(
                                      "LanguidSheep", "FlutterTestMaster", {
                                    "title": CommonUtils.getLocale(context)
                                        .home_reply,
                                    "body": context
                                  }).then((result) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                },
                                titleController: new TextEditingController(),
                                valueController: new TextEditingController(),
                                needTitle: false,
                              );
                            }),

                        /// 查看历史
                        new ListTile(
                          title: new Text(
                            CommonUtils.getLocale(context).home_history,
                            style: CGQTextsConstant.normalText,
                          ),
                          onTap: () {
                            NavigatorUtils.gotoCommonList(
                                context,
                                CommonUtils.getLocale(context).home_history,
                                "repository",
                                "history",
                                userName: "",
                                reposName: "");
                          },
                        ),

                        /// 跳转用户配置的Item
                        new ListTile(
                          title: new Hero(
                            tag: "home_user_info",
                            child: new Material(
                              color: Colors.transparent,
                              child: new Text(
                                CommonUtils.getLocale(context).home_user_info,
                                style: CGQTextsConstant.normalTextBold,
                              ),
                            ),
                          ),
                          onTap: () {
                            NavigatorUtils.gotoUserProfileInfo(context);
                          },
                        ),

                        /// 更改主题颜色
                        new ListTile(
                          title: new Text(
                            CommonUtils.getLocale(context).home_change_theme,
                            style: CGQTextsConstant.normalText,
                          ),
                          onTap: () {
                            showThemeDialog(context, store);
                          },
                        ),

                        /// 更改国际化语言
                        new ListTile(
                          title: new Text(
                            CommonUtils.getLocale(context).home_change_language,
                            style: CGQTextsConstant.normalText,
                          ),
                          onTap: () {
                            showLanguageDialog(context, store);
                          },
                        ),

                        /// 版本更新
                        new ListTile(
                          title: new Text(
                            CommonUtils.getLocale(context).home_check_update,
                            style: CGQTextsConstant.normalText,
                          ),
                          onTap: () {
                            ReposDao.getNewsVersion(context, true);
                          },
                        ),

                        /// 关于
                        new ListTile(
                          title: new Text(
                            CommonUtils.getLocale(context).home_about,
                            style: CGQTextsConstant.normalText,
                          ),
                          onTap: () {
                            PackageInfo.fromPlatform().then((value) {
                              print(value);
                              showAboutDialog(context, value.version);
                            });
                          },
                        ),

                        /// 账号登出
                        new ListTile(
                          title: new CGQFlexButton(
                            text: CommonUtils.getLocale(context).Login_out,
                            color: Colors.redAccent,
                            textColor: Color(CGQColorsConstant.textWhite),
                            onPress: () {
                              UserDao.clearAll(store);
                              SqlManager.close();
                              /// 退出登录返回登录界面
                              NavigatorUtils.goLogin(context);
                            },
                          ),
                          onTap: () {},
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
