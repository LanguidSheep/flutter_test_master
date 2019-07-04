import 'package:dio/dio.dart';
import 'package:flutter_test_master/common/net/address.dart';
import 'package:flutter_test_master/common/net/api.dart';

import 'dao_result.dart';

/// issue_dao
/// Created by Chen_Mr on 2019/6/27.

class IssueDao {

  ///  创建issue
  static createIssueDao(userName, repository, issue) async {
    String url = Address.createIssue(userName, repository);
    var res = await httpManager.netFetch(url, issue, {"Accept": 'application/vnd.github.VERSION.full+json'}, new Options(method: 'POST'));
    if (res != null && res.result) {
      return new DataResult(res.data, true);
    } else {
      return new DataResult(null, false);
    }
  }
}