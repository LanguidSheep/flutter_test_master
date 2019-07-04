import 'package:flutter_test_master/dao/event_dao.dart';

import 'base/base_bloc.dart';

class DynamicBloc extends BlocListBase {

  /// 数据获取：下拉刷新获取数据
  requestRefresh(String userName) async {
    pageReset();
    var res =
        await EventDao.getEventReceived(userName, page: page, needDb: true);
    changeLoadMoreStatus(getLoadMoreStatus(res));
    refreshData(res);
    await doNext(res);
    return res;
  }

  /// 数据获取：上拉加载获取数据
  requestLoadMore(String userName) async {
    pageUp();
    var res = await EventDao.getEventReceived(userName, page: page);
    changeLoadMoreStatus(getLoadMoreStatus(res));
    loadMoreData(res);
    return res;
  }
}
