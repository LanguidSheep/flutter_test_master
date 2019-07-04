import 'package:flutter/material.dart';
import 'package:flutter_test_master/dao/ReposDao.dart';
import 'package:flutter_test_master/dao/event_dao.dart';
import 'package:flutter_test_master/dao/user_dao.dart';
import 'package:flutter_test_master/entity/User.dart';
import 'package:flutter_test_master/entity/UserOrg.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/widgets/cgq_common_option_widget.dart';
import 'package:flutter_test_master/widgets/cgq_title_bar.dart';
import 'package:flutter_test_master/widgets/pull/nested/cgq_nested_pull_load_widget.dart';
import 'package:flutter_test_master/widgets/state/base_person_state.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// person_page
/// Created by Chen_Mr on 2019/7/2.

class PersonPage extends StatefulWidget {
  static final String sName = "person";

  final String userName;

  PersonPage(this.userName, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PersonState(userName);
  }
}

class _PersonState extends BasePersonState<PersonPage> {
  final String userName;

  String beStaredCount = "---";

  bool focusStatus = false;

  String focus = "";

  User userInfo = User.empty();

  final List<UserOrg> orgList = new List();

  final OptionControl titleOptionControl = new OptionControl();

  _PersonState(this.userName);

  ///处理用户信息显示
  _resolveUserInfo(res) {
    if (isShow) {
      setState(() {
        userInfo = res.data;
        titleOptionControl.url = res.data.html_url;
      });
    }
  }

  @override
  Future<Null> handleRefresh() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page = 1;

    ///获取网络用户数据
    var userResult = await UserDao.getUserInfo(userName, needDb: true);
    if (userResult != null && userResult.result) {
      _resolveUserInfo(userResult);
      if (userResult.next != null) {
        userResult.next.then((resNext) {
          _resolveUserInfo(resNext);
        });
      }
    } else {
      return null;
    }

    ///获取用户动态或者组织成员
    var res = await _getDataLogic();
    resolveRefreshResult(res);
    resolveDataResult(res);
    if (res.next != null) {
      var resNext = await res.next;
      resolveRefreshResult(resNext);
      resolveDataResult(resNext);
    }
    isLoading = false;

    ///获取当前用户的关注状态
    _getFocusStatus();

    ///获取用户仓库前100个star统计数据
    ReposDao.getUserRepository100StatusDao(_getUserName()).then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            beStaredCount = res.data.toString();
          });
        }
      }
    });
    return null;
  }

  ///获取当前用户的关注状态
  _getFocusStatus() async {
    var focusRes = await UserDao.checkFollowDao(userName);
    if (isShow) {
      setState(() {
        focus = (focusRes != null && focusRes.result)
            ? CommonUtils.getLocale(context).user_focus
            : CommonUtils.getLocale(context).user_un_focus;
        focusStatus = (focusRes != null && focusRes.result);
      });
    }
  }

  ///获取用户信息里的用户名
  _getUserName() {
    if (userInfo == null) {
      return new User.empty();
    }
    return userInfo.login;
  }

  ///获取用户动态或者组织成员
  _getDataLogic() async {
    if (userInfo.type == "Organization") {
      return await UserDao.getMemberDao(_getUserName(), page);
    }
    getUserOrg(_getUserName());
    return await EventDao.getEventDao(_getUserName(),
        page: page, needDb: page <= 1);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {}

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
        appBar: new AppBar(
            title: CGQTitleBar(
          title: (userInfo != null && userInfo.login != null)
              ? userInfo.login
              : "",
          rightWidget: GSYCommonOptionWidget(titleOptionControl),
        )),
        floatingActionButton: new FloatingActionButton(
            child: new Text(focus),
            onPressed: () {
              ///非组织成员可以关注
              if (focus == '') {
                return;
              }
              if (userInfo.type == "Organization") {
                Fluttertoast.showToast(
                    msg: CommonUtils.getLocale(context).user_focus_no_support);
                return;
              }
              CommonUtils.showLoadingDialog(context);
              UserDao.doFollowDao(userName, focusStatus).then((res) {
                Navigator.pop(context);
                _getFocusStatus();
              });
            }),
        body: CGQNestedPullLoadWidget(
          pullLoadWidgetControl,
          (BuildContext context, int index) =>
              renderItem(index, userInfo, beStaredCount, null, null, orgList),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshKey,
          headerSliverBuilder: (context, _) {
            return sliverBuilder(
                context, _, userInfo, null, beStaredCount, null);
          },
        ));
  }
}
