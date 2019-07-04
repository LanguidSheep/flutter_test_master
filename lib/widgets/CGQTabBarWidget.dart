import 'package:flutter/material.dart';

/// CGQTabBarWidget：TabBar组件
/// TabBarWidget Created by Chen_Mr on 2019/6/12.

class CGQTabBarWidget extends StatefulWidget {
  /// 底部Tab导航栏模式
  static const int BOTTOM_TAB = 1;

  ///顶部Tab导航栏模式
  static const int TOP_TAB = 2;

  /// 导航栏模式标记值
  final int type;

  /// 导航栏子级Item集合
  final List<Widget> tabItems;

  /// Tab页面的View集合
  final List<Widget> tabViews;

  final Color backgroundColor;

  /// 导航栏指示器颜色
  final Color indicatorColor;

  /// 标题
  final Widget title;

  /// 侧边划出方式
  final Widget drawer;

  /// 悬浮按钮  可以不添加
  final Widget floatingActionButton;

  final TarWidgetControl tarWidgetControl;

  /// page页面控制器
  final PageController topPageControl;

  CGQTabBarWidget(
      {Key key,
      this.type,
      this.tabItems,
      this.tabViews,
      this.backgroundColor,
      this.indicatorColor,
      this.title,
      this.drawer,
      this.floatingActionButton,
      this.tarWidgetControl,
      this.topPageControl})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _CGQTabBarState(type, tabItems, tabViews, backgroundColor,
        indicatorColor, title, drawer, floatingActionButton, topPageControl);
  }
}

class _CGQTabBarState extends State<CGQTabBarWidget>
    with SingleTickerProviderStateMixin {
  final int _type;

  final List<Widget> _tabItems;

  final List<Widget> _tabViews;

  final Color _backgroundColor;

  final Color _indicatorColor;

  final Widget _title;

  final Widget _drawer;

  final Widget _floatingActionButton;

  final PageController _pageController;

  TabController _tabController;

  _CGQTabBarState(
      this._type,
      this._tabItems,
      this._tabViews,
      this._backgroundColor,
      this._indicatorColor,
      this._title,
      this._drawer,
      this._floatingActionButton,
      this._pageController)
      : super();

  @override
  void initState() {
    super.initState();

    /// 初始化时创建控制器
    /// 通过with singleTickerProviderStateMixin 实现动画效果
    _tabController = new TabController(length: _tabItems.length, vsync: this);
  }

  @override
  void dispose() {
    /// 页面销毁时 销毁控制器
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 顶部TabBar模式
    if (this._type == CGQTabBarWidget.TOP_TAB) {
      return new Scaffold(
        /// 设置侧边划出drawer，不需要可以不设置
        drawer: _drawer,

        /// 设置悬浮按钮，不需要刻意不设置
        floatingActionButton: _floatingActionButton,

        /// 标题栏
        appBar: new AppBar(
          backgroundColor: _backgroundColor,
          title: _title,
          bottom: new TabBar(
            /// 顶部时，tabBar为可以滑动的模式
            isScrollable: true,

            /// 控制器，与pageView的控制器同步
            controller: _tabController,

            /// 每一个tabItem，是一个List<Widget>
            tabs: _tabItems,

            /// tab底部选中条颜色
            indicatorColor: _indicatorColor,
          ),
        ),

        /// 页面主题部分  PageView，用户承载Tab对应的界面
        body: new PageView(
          /// 控制器，与tabBar的控制同步
          controller: _pageController,

          /// 每个Tab对应的页面主题   是一个List<Widget>
          children: _tabViews,

          /// 页面滑动回调，用户同步Tab选中状态
          onPageChanged: (index) {
            _tabController.animateTo(index);
          },
        ),
      );
    }
    return new Scaffold(

        ///设置侧边滑出 drawer，不需要可以不设置
        drawer: _drawer,

        ///设置悬浮按键，不需要可以不设置
        floatingActionButton: _floatingActionButton,

        ///标题栏
        appBar: new AppBar(
          backgroundColor: _backgroundColor,
          title: _title,
        ),

        ///页面主体，PageView，用于承载Tab对应的页面
        body: new PageView(
          ///必须有的控制器，与tabBar的控制器同步
          controller: _pageController,

          ///每一个 tab 对应的页面主体，是一个List<Widget>
          children: _tabViews,
          onPageChanged: (index) {
            ///页面触摸作用滑动回调，用于同步tab选中状态
            _tabController.animateTo(index);
          },
        ),

        ///底部导航栏，也就是tab栏
        bottomNavigationBar: new Material(
          color: _backgroundColor,

          ///tabBar控件
          child: new TabBar(
            ///必须有的控制器，与pageView的控制器同步
            controller: _tabController,

            /// 顶部时，tabBar为可以滑动的模式
            isScrollable: true,

            ///每一个tab item，是一个List<Widget>
            tabs: _tabItems,

            ///tab底部选中条颜色
            indicatorColor: _indicatorColor,
          ),
        ));
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
