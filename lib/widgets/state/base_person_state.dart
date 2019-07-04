import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test_master/dao/user_dao.dart';
import 'package:flutter_test_master/entity/Event.dart';
import 'package:flutter_test_master/entity/User.dart';
import 'package:flutter_test_master/entity/UserOrg.dart';
import 'package:flutter_test_master/utils/event_utils.dart';
import 'package:flutter_test_master/utils/navigator_utils.dart';
import 'package:flutter_test_master/widgets/pull/nested/cgq_sliver_header_delegate.dart';
import 'package:flutter_test_master/widgets/pull/nested/nested_refresh.dart';

import '../event_item.dart';
import '../user_header.dart';
import '../user_item.dart';
import 'cgq_list_state.dart';

/// base_person_state
/// Created by Chen_Mr on 2019/7/2.

class BasePersonState<T extends StatefulWidget> extends State<T>
    with
        AutomaticKeepAliveClientMixin<T>,
        CGQListState<T>,
        SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewRefreshIndicatorState> refreshKey =
      new GlobalKey<NestedScrollViewRefreshIndicatorState>();

  final List<UserOrg> orgList = new List();

  @override
  showRefreshLoading() {
    new Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  @protected
  renderItem(index, User userInfo, String beStaredCount, Color notifyColor,
      VoidCallback refreshCallBack, List<UserOrg> orgList) {
    if (userInfo.type == "organization") {
      return new UserItem(
        UserItemViewModel.fromMap(pullLoadWidgetControl.dataList[index]),
        onPressed: () {
          NavigatorUtils.goPerson(
              context,
              UserItemViewModel.fromMap(pullLoadWidgetControl.dataList[index])
                  .userName);
        },
      );
    } else {
      Event event = pullLoadWidgetControl.dataList[index];
      return new EventItem(
        EventViewModel.fromEventMap(event),
        onPressed: () {
          EventUtils.ActionUtils(context, event, "");
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => true;

  @protected
  getUserOrg(String userName){
    if(page <=1 && userName !=null){
      UserDao.getUserOrgsDao(userName,page,needDb: true).then((res){
        if(res !=null && res.result){
          setState(() {
            orgList.clear();
            orgList.addAll(res.data);
          });
          return res.next;
        }
        return new Future.value(null);
      }).then((res){
        if(res != null && res.result){
          setState(() {
            orgList.clear();
            orgList.addAll(res.data);
          });
        }
      });
    }
  }

  @protected
  List<Widget> sliverBuilder(BuildContext context, bool innerBoxIsScrolled,
      User userInfo, Color notifyColor, String beStaredCount, refreshCallBack) {
    double headerSize = 210;
    double bottomSize = 70;
    double chartSize =    (userInfo.login != null && userInfo.type == "Organization") ? 70 : 215;
    return <Widget>[
      ///头部信息
      SliverPersistentHeader(
        pinned: true,
        delegate: CGQSliverHeaderDelegate(
            maxHeight: headerSize,
            minHeight: headerSize,
            changeSize: true,
            snapConfig: FloatingHeaderSnapConfiguration(
              vsync: this,
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 10),
            ),
            builder: (BuildContext context, double shrinkOffset,
                bool overlapsContent) {
              return Transform.translate(
                offset: Offset(0, -shrinkOffset),
                child: SizedBox.expand(
                  child: Container(
                    child: new UserHeaderItem(
                        userInfo, beStaredCount, Theme.of(context).primaryColor,
                        notifyColor: notifyColor,
                        refreshCallBack: refreshCallBack,
                        orgList: orgList),
                  ),
                ),
              );
            }),
      ),

      ///悬停的item
      SliverPersistentHeader(
        pinned: true,
        floating: true,
        delegate: CGQSliverHeaderDelegate(
            maxHeight: bottomSize,
            minHeight: bottomSize,
            changeSize: true,
            snapConfig: FloatingHeaderSnapConfiguration(
              vsync: this,
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 10),
            ),
            builder: (BuildContext context, double shrinkOffset,
                bool overlapsContent) {
              var radius = Radius.circular(10 - shrinkOffset / bottomSize * 10);
              return SizedBox.expand(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 0, right: 0),
                  child: UserHeaderBottom(userInfo, beStaredCount, radius),
                ),
              );
            }),
      ),

      ///提交图表
      SliverPersistentHeader(
        delegate: CGQSliverHeaderDelegate(
            maxHeight: chartSize,
            minHeight: chartSize,
            changeSize: true,
            snapConfig: FloatingHeaderSnapConfiguration(
              vsync: this,
              curve: Curves.bounceInOut,
              duration: const Duration(milliseconds: 10),
            ),
            builder: (BuildContext context, double shrinkOffset,
                bool overlapsContent) {
              return SizedBox.expand(
                child: Container(
                  height: chartSize,
                  child: UserHeaderChart(userInfo),
                ),
              );
            }),
      ),
    ];
  }
}
