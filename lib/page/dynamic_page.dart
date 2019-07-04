import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test_master/widgets/pull/cgq_pull_new_load_widget.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test_master/bloc/base/base_bloc.dart';
import 'package:flutter_test_master/bloc/dynamic_bloc.dart';
import 'package:flutter_test_master/common/redux/cgq_state.dart';
import 'package:flutter_test_master/dao/ReposDao.dart';
import 'package:flutter_test_master/entity/Event.dart';
import 'package:flutter_test_master/utils/event_utils.dart';
import 'package:flutter_test_master/widgets/event_item.dart';
import 'package:flutter_test_master/widgets/state/cgq_list_state.dart';

/// dynamic_page：主页动态tab页面
/// Created by Chen_Mr on 2019/6/27.

class DynamicPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DynamicPageState();
  }
}

class _DynamicPageState extends State<DynamicPage>
    with
        AutomaticKeepAliveClientMixin<DynamicPage>,
        CGQListState<DynamicPage>,
        WidgetsBindingObserver {

  final DynamicBloc dynamicBloc = new DynamicBloc();

  ///控制列表滚动和监听
  final ScrollController scrollController = new ScrollController();

  /// 模拟IOS下拉显示刷新
  @override
  showRefreshLoading() {
    ///直接触发下拉
    new Future.delayed(const Duration(milliseconds: 500), () {
      scrollController.animateTo(-141,
          duration: Duration(milliseconds: 600), curve: Curves.linear);
      return true;
    });
  }

  /// 下拉刷新
  @override
  requestRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    return await dynamicBloc.requestRefresh(_getStore().state.userInfo?.login);
  }

  /// 加载更多
  @override
  requestLoadMore() async {
    return await dynamicBloc.requestLoadMore(_getStore().state.userInfo?.login);
  }

  @override
  bool get isRefreshFirst => false;

  @override
  BlocListBase get bloc => dynamicBloc;

  @override
  void initState() {
    super.initState();

    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
    WidgetsBinding.instance.addObserver(this);

    ///获取网络端新版信息
    ReposDao.getNewsVersion(context, false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (bloc.getDataLength() == 0) {
      showRefreshLoading();
    }
    super.didChangeDependencies();
  }

  ///监听生命周期，主要判断页面 resumed 的时候触发刷新
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (bloc.getDataLength() != 0) {
        showRefreshLoading();
      }
    }
  }

  _renderEventItem(Event e) {
    EventViewModel eventViewModel = EventViewModel.fromEventMap(e);
    return new EventItem(
      eventViewModel,
      onPressed: () {
        EventUtils.ActionUtils(context, e, "");
      },
    );
  }

  Store<CGQState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return new StoreBuilder<CGQState>(
      builder: (context, store) {
        ///BlocProvider 用于管理 bloc 共享，如果不需要共享可以不用
        ///直接 StreamBuilder 配合即可
        return BlocProvider<DynamicBloc>(
          bloc: dynamicBloc,
          child: CGQPullLoadWidget(
            bloc.pullLoadWidgetControl,
            (BuildContext context, int index) =>
                _renderEventItem(bloc.dataList[index]),
            requestRefresh,
            requestLoadMore,
            refreshKey: refreshIndicatorKey,
            scrollController: scrollController,

            ///是否使用ios模式的下拉刷新
            userIos: true,
          ),
        );
      },
    );
  }
}
