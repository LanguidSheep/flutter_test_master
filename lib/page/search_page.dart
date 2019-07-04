import 'package:flutter/material.dart';
import 'package:flutter_test_master/common/config.dart';
import 'package:flutter_test_master/dao/ReposDao.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/utils/navigator_utils.dart';
import 'package:flutter_test_master/widgets/pull/cgq_pull_load_widget.dart';
import 'package:flutter_test_master/widgets/cgq_search_drawer.dart';
import 'package:flutter_test_master/widgets/cgq_search_input_widget.dart';
import 'package:flutter_test_master/widgets/cgq_select_item_widget.dart';
import 'package:flutter_test_master/widgets/repos_item.dart';
import 'package:flutter_test_master/widgets/state/cgq_list_state.dart';
import 'package:flutter_test_master/widgets/user_item.dart';

/// search_page: 搜索页面
/// Created by Chen_Mr on 2019/6/27.

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage>, CGQListState {
  ///搜索仓库还是人
  int selectIndex = 0;

  ///搜索文件
  String searchText;

  ///排序类型
  String type = searchFilterType[0].value;

  ///排序
  String sort = sortType[0].value;

  ///过滤语言
  String language = searchLanguageType[0].value;

  ///绘制item
  _renderItem(index) {
    var data = pullLoadWidgetControl.dataList[index];
    if (selectIndex == 0) {
      /// 搜索的仓库
      ReposViewModel reposViewModel = ReposViewModel.fromMap(data);
      return new ReposItem(reposViewModel, onPressed: () {
        NavigatorUtils.goReposDetail(
            context, reposViewModel.ownerName, reposViewModel.repositoryName);
      });
    } else if (selectIndex == 1) {
      /// 搜索的人
      return new UserItem(UserItemViewModel.fromMap(data), onPressed: () {
        NavigatorUtils.goPerson(
            context, UserItemViewModel.fromMap(data).userName);
      });
    }
  }

  ///切换tab
  _resolveSelectIndex() {
    clearData();
    showRefreshLoading();
  }

  ///获取搜索数据
  _getDataLogic() async {
    return await ReposDao.searchRepositoryDao(searchText, language, type, sort,
        selectIndex == 0 ? null : 'user', page, Config.PAGE_SIZE);
  }

  ///清空过滤数据
  _clearSelect(List<FilterModel> list) {
    for (FilterModel model in list) {
      model.select = false;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  bool get needHeader => false;

  @override
  bool get isRefreshFirst => null;

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  requestRefresh() async {
    return await _getDataLogic();
  }

  @override
  void dispose() {
    super.dispose();
    _clearSelect(sortType);
    sortType[0].select = true;
    _clearSelect(searchLanguageType);
    searchLanguageType[0].select = true;
    _clearSelect(searchFilterType);
    searchFilterType[0].select = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return new Scaffold(
      resizeToAvoidBottomPadding: false,

      ///右侧 Drawer
      endDrawer: new CGQSearchDrawer(
        (String type) {
          ///排序类型
          this.type = type;
          Navigator.pop(context);
          _resolveSelectIndex();
        },
        (String sort) {
          ///排序状态
          this.sort = sort;
          Navigator.pop(context);
          _resolveSelectIndex();
        },
        (String language) {
          ///过滤语言
          this.language = language;
          Navigator.pop(context);
          _resolveSelectIndex();
        },
      ),
      backgroundColor: Color(CGQColorsConstant.mainBackgroundColor),
      appBar: new AppBar(
          title: new Text(CommonUtils.getLocale(context).search_title),
          bottom: new SearchBottom((value) {
            searchText = value;
          }, (value) {
            searchText = value;
            if (searchText == null || searchText.trim().length == 0) {
              return;
            }
            if (isLoading) {
              return;
            }
            _resolveSelectIndex();
          }, () {
            if (searchText == null || searchText.trim().length == 0) {
              return;
            }
            if (isLoading) {
              return;
            }
            _resolveSelectIndex();
          }, (selectIndex) {
            if (searchText == null || searchText.trim().length == 0) {
              return;
            }
            if (isLoading) {
              return;
            }
            this.selectIndex = selectIndex;
            _resolveSelectIndex();
          })),
      body: CGQPullLoadWidget(
        (BuildContext context, int index) => _renderItem(index),
        onLoadMore,
        pullLoadWidgetControl,
        handleRefresh,
        refreshKey: refreshIndicatorKey,
      ),
    );
  }
}

///实现 PreferredSizeWidget 实现自定义 appbar bottom 控件
class SearchBottom extends StatelessWidget implements PreferredSizeWidget {
  final SelectItemChanged onChanged;

  final SelectItemChanged onSubmitted;

  final SelectItemChanged selectItemChanged;

  final VoidCallback onSubmitPressed;

  SearchBottom(this.onChanged, this.onSubmitted, this.onSubmitPressed,
      this.selectItemChanged);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CGQSearchInputWidget(onChanged, onSubmitted, onSubmitPressed),
        new CGQSelectItemWidget(
          [
            CommonUtils.getLocale(context).search_tab_repos,
            CommonUtils.getLocale(context).search_tab_user,
          ],
          selectItemChanged,
          elevation: 0.0,
          margin: const EdgeInsets.all(5.0),
        )
      ],
    );
  }

  @override
  Size get preferredSize {
    return new Size.fromHeight(100.0);
  }
}
