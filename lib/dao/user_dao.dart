import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test_master/common/config.dart';
import 'package:flutter_test_master/common/db/provider/user/user_followed_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/user/user_follower_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/user/user_orgs_db_provider.dart';
import 'package:flutter_test_master/common/db/provider/user/userinfo_db_provider.dart';
import 'package:flutter_test_master/common/local/local_storage.dart';
import 'package:flutter_test_master/common/net/address.dart';
import 'package:flutter_test_master/common/net/api.dart';
import 'package:flutter_test_master/common/net_config.dart';
import 'package:flutter_test_master/common/redux/user_redux.dart';
import 'package:flutter_test_master/entity/Notification.dart';
import 'package:flutter_test_master/entity/User.dart';
import 'package:flutter_test_master/entity/UserOrg.dart';

import 'package:redux/redux.dart';

import 'dao_result.dart';

/// user_dao
/// Created by Chen_Mr on 2019/6/17.

class UserDao {
  static login(userName, password, store) async {
    String type = userName + ":" + password;
    var bytes = utf8.encode(type);
    var base64Str = base64.encode(bytes);
    if (Config.DEBUG) {
      print("base64Str login " + base64Str);
    }
    await LocalStorage.save(Config.USER_NAME_KEY, userName);
    await LocalStorage.save(Config.USER_BASIC_CODE, base64Str);

    Map requestParams = {
      "scopes": ['user', 'repo', 'gist', 'notifications'],
      "note": "admin_script",
      "client_id": NetConfig.CLIENT_ID,
      "client_secret": NetConfig.CLIENT_SECRET
    };
    httpManager.clearAuthorization();

    var res = await httpManager.netFetch(Address.getAuthorization(),
        json.encode(requestParams), null, new Options(method: "post"));
    var resultData = null;
    if (res != null && res.result) {
      await LocalStorage.save(Config.PW_KEY, password);
      var resultData = await getUserInfo(null);
      if (Config.DEBUG) {
        print("user result " + resultData.result.toString());
        print(resultData.data);
        print(res.data.toString());
      }
      store.dispatch(new UpdateUserAction(resultData.data));
    }
    return new DataResult(resultData, res.result);
  }

  ///初始化用户信息
  static initUserInfo(Store store) async {
    /// 获取本地偏好文件保存的Token
    var token = await LocalStorage.get(Config.TOKEN_KEY);

    /// 从偏好文件中获取到的用户信息
    var res = await getUserInfoLocal();

    /// 判断是否成功登录用户
    if (res != null && res.result && token != null) {
      /// 更新全局唯一的store中的UserInfo属性
      store.dispatch(UpdateUserAction(res.data));
    }
  }

  /// 获取用户本地登录信息
  static getUserInfoLocal() async {
    /// 从偏好文件中获取用户信息
    var userText = await LocalStorage.get(Config.USER_INFO);
    if (userText != null) {
      /// json序列化 转为User对象
      var userMap = json.decode(userText);
      User user = User.fromJson(userMap);
      return new DataResult(user, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /// 获取用户详细信息
  static getUserInfo(userName, {needDb = false}) async {
    UserInfoDbProvider provider = new UserInfoDbProvider();
    next() async {
      var res;
      if (userName == null) {
        res = await httpManager.netFetch(
            Address.getMyUserInfo(), null, null, null);
      } else {
        res = await httpManager.netFetch(
            Address.getUserInfo(userName), null, null, null);
      }
      if (res != null && res.result) {
        String starred = "---";
        if (res.data["type"] != "Organization") {
          var countRes = await getUserStaredCountNet(res.data["login"]);
          if (countRes.result) {
            starred = countRes.data;
          }
        }
        User user = User.fromJson(res.data);
        user.starred = starred;
        if (userName == null) {
          LocalStorage.save(Config.USER_INFO, json.encode(user.toJson()));
        } else {
          if (needDb) {
            provider.insert(userName, json.encode(user.toJson()));
          }
        }
        return new DataResult(user, true);
      } else {
        return new DataResult(res.data, false);
      }
    }

    if (needDb) {
      User user = await provider.getUserInfo(userName);
      if (user == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(user, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户粉丝列表
   */
  static getFollowerListDao(userName, page, {needDb = false}) async {
    UserFollowerDbProvider provider = new UserFollowerDbProvider();

    next() async {
      String url = Address.getUserFollower(userName) + Address.getPageParams("?", page);
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
          provider.insert(userName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户相关通知
   */
  static getNotifyDao(bool all, bool participating, page) async {
    String tag = (!all && !participating) ? '?' : "&";
    String url = Address.getNotifation(all, participating) + Address.getPageParams(tag, page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<Notification> list = new List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return new DataResult([], true);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(Notification.fromJson(data[i]));
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 获取用户关注列表
   */
  static getFollowedListDao(userName, page, {needDb = false}) async {
    UserFollowedDbProvider provider = new UserFollowedDbProvider();
    next() async {
      String url = Address.getUserFollow(userName) + Address.getPageParams("?", page);
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
          provider.insert(userName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 关注用户
   */
  static doFollowDao(name, bool followed) async {
    String url = Address.doFollow(name);
    var res = await httpManager.netFetch(url, null, null, new Options(method: !followed ? "PUT" : "DELETE"), noTip: true);
    return new DataResult(res.data, res.result);
  }

  /// 检查用户关注状态
  static checkFollowDao(name) async {
    String url = Address.doFollow(name);
    var res = await httpManager.netFetch(url, null, null, new Options(contentType: ContentType.text), noTip: true);
    return new DataResult(res.data, res.result);
  }

  /// 组织成员
  static getMemberDao(userName, page) async {
    String url = Address.getMember(userName) + Address.getPageParams("?", page);
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
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /// 清除当前登录用户信息
  static clearAll(Store store){
    httpManager.clearAuthorization();
    LocalStorage.remove(Config.USER_INFO);
    // 全局User置空
    store.dispatch(new UpdateUserAction(User.empty()));
  }

  /// 在header中提起stared count
  static getUserStaredCountNet(userName) async {
    String url = Address.userStar(userName, null) + "&per_page=1";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.headers != null) {
      try {
        List<String> link = res.headers['link'];
        if (link != null) {
          int indexStart = link[0].lastIndexOf("page=") + 5;
          int indexEnd = link[0].lastIndexOf(">");
          if (indexStart >= 0 && indexEnd >= 0) {
            String count = link[0].substring(indexStart, indexEnd);
            return new DataResult(count, true);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return new DataResult(null, false);
  }

  /**
   * 获取用户组织
   */
  static getUserOrgsDao(userName, page, {needDb = false}) async {
    UserOrgsDbProvider provider = new UserOrgsDbProvider();
    next() async {
      String url = Address.getUserOrgs(userName) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<UserOrg> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(new UserOrg.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(userName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<UserOrg> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }
}
