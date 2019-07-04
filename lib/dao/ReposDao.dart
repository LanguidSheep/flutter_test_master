import 'dart:convert';
import 'dart:io';

import 'package:flutter_test_master/common/config.dart';
import 'package:flutter_test_master/common/db/provider/repos/read_history_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/repos/repository_fork_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/repos/repository_star_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/repos/repository_watcher_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/repos/trend_repository_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/user/user_repos_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/user/user_stared_db_provider.dart';
import 'package:flutter_test_master/common/net/address.dart';
import 'package:flutter_test_master/common/net/api.dart';
import 'package:flutter_test_master/common/net/trending/github_trending.dart';
import 'package:flutter_test_master/entity/Release.dart';
import 'package:flutter_test_master/entity/Repository.dart';
import 'package:flutter_test_master/entity/TrendingRepoModel.dart';
import 'package:flutter_test_master/entity/User.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dao_result.dart';

/// ReposDao
/// Created by Chen_Mr on 2019/6/27.

class ReposDao {

  /**
   * 趋势数据
   * @param page 分页，趋势数据其实没有分页
   * @param since 数据时长， 本日，本周，本月
   * @param languageType 语言
   */
  static getTrendDao({since = 'daily', languageType, page = 0, needDb = true}) async {
    TrendRepositoryDbProvider provider = new TrendRepositoryDbProvider();
    String languageTypeDb = languageType ?? "*";

    next() async {
      String url = Address.trending(since, languageType);
      var res = await new GitHubTrending().fetchTrending(url);
      if (res != null && res.result && res.data.length > 0) {
        List<TrendingRepoModel> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        if (needDb) {
          provider.insert(languageTypeDb, since, json.encode(data));
        }
        for (int i = 0; i < data.length; i++) {
          TrendingRepoModel model = data[i];
          list.add(model);
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<TrendingRepoModel> list = await provider.getData(languageTypeDb, since);
      if (list == null || list.length == 0) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
  }

  /**
   * 搜索仓库
   * @param q 搜索关键字
   * @param sort 分类排序，beat match、most star等
   * @param order 倒序或者正序
   * @param type 搜索类型，人或者仓库 null \ 'user',
   * @param page
   * @param pageSize
   */
  static searchRepositoryDao(
      q, language, sort, order, type, page, pageSize) async {
    if (language != null) {
      q = q + "%2Blanguage%3A$language";
    }
    String url = Address.search(q, sort, order, type, page, pageSize);
    var res = await httpManager.netFetch(url, null, null, null);
    if (type == null) {
      if (res != null && res.result && res.data["items"] != null) {
        List<Repository> list = new List();
        var dataList = res.data["items"];
        if (dataList == null || dataList.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    } else {
      if (res != null && res.result && res.data["items"] != null) {
        List<User> list = new List();
        var data = res.data["items"];
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(new User.fromJson(data[i]));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }
  }

  /**
   * 版本更新
   */
  static getNewsVersion(context, showTip) async {
    //ios不检查更新
    if (Platform.isIOS) {
      return;
    }
    var res = await getRepositoryReleaseDao("LanguidSheep", 'FlutterTestMaster', 1,
        needHtml: false);
    if (res != null && res.result && res.data.length > 0) {
      Release release = res.data[0];
      String versionName = release.name;
      if (versionName != null) {
        if (Config.DEBUG) {
          print("versionName " + versionName);
        }

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        var appVersion = packageInfo.version;

        if (Config.DEBUG) {
          print("appVersion " + appVersion);
        }
        Version versionNameNum = Version.parse(versionName);
        Version currentNum = Version.parse(appVersion);
        int result = versionNameNum.compareTo(currentNum);
        if (Config.DEBUG) {
          print("versionNameNum " +
              versionNameNum.toString() +
              " currentNum " +
              currentNum.toString());
        }
        if (Config.DEBUG) {
          print("newsHad " + result.toString());
        }
        if (result > 0) {
          CommonUtils.showUpdateDialog(
              context, release.name + ": " + release.body);
        } else {
          if (showTip)
            Fluttertoast.showToast(
                msg: CommonUtils.getLocale(context).app_not_new_version);
        }
      }
    }
  }

  /**
   * 获取用户所有star
   */
  static getStarRepositoryDao(userName, page, sort, {needDb = false}) async {
    UserStaredDbProvider provider = new UserStaredDbProvider();
    next() async {
      String url = Address.userStar(userName, sort) + Address.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = new List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(userName, json.encode(dataList));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 用户的仓库
   */
  static getUserRepositoryDao(userName, page, sort, {needDb = false}) async {
    UserReposDbProvider provider = new UserReposDbProvider();
    next() async {
      String url = Address.userRepos(userName, sort) + Address.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = new List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(userName, json.encode(dataList));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取当前仓库所有star用户
   */
  static getRepositoryStarDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryStarDbProvider provider = new RepositoryStarDbProvider();
    next() async {
      String url = Address.getReposStar(userName, reposName) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(new User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取当前仓库所有订阅用户
   */
  static getRepositoryWatcherDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryWatcherDbProvider provider = new RepositoryWatcherDbProvider();

    next() async {
      String url = Address.getReposWatcher(userName, reposName) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(new User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取仓库的fork分支
   */
  static getRepositoryForksDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryForkDbProvider provider = new RepositoryForkDbProvider();
    next() async {
      String url = Address.getReposForks(userName, reposName) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = new List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(dataList));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 用户的前100仓库
   */
  static getUserRepository100StatusDao(userName) async {
    String url = Address.userRepos(userName, 'pushed') + "&page=1&per_page=100";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.data.length > 0) {
      int stared = 0;
      for (int i = 0; i < res.data.length; i++) {
        var data = res.data[i];
        stared += data["watchers_count"];
      }
      return new DataResult(stared, true);
    }
    return new DataResult(null, false);
  }

  /// 获取仓库的release列表
  static getRepositoryReleaseDao(userName, reposName, page,
      {needHtml = true, release = true}) async {
    String url = release
        ? Address.getReposRelease(userName, reposName) +
            Address.getPageParams("?", page)
        : Address.getReposTag(userName, reposName) +
            Address.getPageParams("?", page);

    var res = await httpManager.netFetch(
        url,
        null,
        {
          "Accept": (needHtml
              ? 'application/vnd.github.html,application/vnd.github.VERSION.raw'
              : "")
        },
        null);
    if (res != null && res.result && res.data.length > 0) {
      List<Release> list = new List();
      var dataList = res.data;
      if (dataList == null || dataList.length == 0) {
        return new DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(Release.fromJson(data));
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 搜索话题
   */
  static searchTopicRepositoryDao(searchTopic, {page = 0}) async {
    String url = Address.searchTopic(searchTopic) + Address.getPageParams("&", page);
    var res = await httpManager.netFetch(url, null, null, null);
    var data = (res.data != null && res.data["items"] != null) ? res.data["items"] : res.data;
    if (res != null && res.result && data != null && data.length > 0) {
      List<Repository> list = new List();
      var dataList = data;
      if (dataList == null || dataList.length == 0) {
        return new DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(Repository.fromJson(data));
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 获取阅读历史
   */
  static getHistoryDao(page) async {
    ReadHistoryDbProvider provider = new ReadHistoryDbProvider();
    List<Repository> list = await provider.geData(page);
    if (list == null || list.length <= 0) {
      return new DataResult(null, false);
    }
    return new DataResult(list, true);
  }

  /**
   * 保存阅读历史
   */
  static saveHistoryDao(String fullName, DateTime dateTime, String data) {
    ReadHistoryDbProvider provider = new ReadHistoryDbProvider();
    provider.insert(fullName, dateTime, data);
  }
}
