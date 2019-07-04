import 'dart:async';

/// 数据传递对象
class DataResult {
  var data;
  bool result;
  Future next;

  DataResult(this.data, this.result, {this.next});
}
