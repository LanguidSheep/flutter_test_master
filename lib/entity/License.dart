import 'package:json_annotation/json_annotation.dart';

/// License
/// Created by Chen_Mr on 2019/6/27.

part 'License.g.dart';

@JsonSerializable()
class License {

  String name;

  License(this.name);

  factory License.fromJson(Map<String, dynamic> json) => _$LicenseFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseToJson(this);
}