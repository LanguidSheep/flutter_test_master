import 'dart:ui';

import 'package:flutter/material.dart';

import 'cgq_string_base.dart';
import 'cgq_string_en.dart';
import 'cgq_string_zh.dart';

///自定义多语言实现
class CGQLocalizations {
  final Locale locale;

  CGQLocalizations(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  ///GSYStringEn和GSYStringZh都继承了GSYStringBase
  static Map<String, CGQStringBase> _localizedValues = {
    'en': new CGQStringEn(),
    'zh': new CGQStringZh(),
  };

  CGQStringBase get currentLocalized {
    return _localizedValues[locale.languageCode];
  }

  ///通过 Localizations 加载当前的 GSYLocalizations
  ///获取对应的 GSYStringBase
  static CGQLocalizations of(BuildContext context) {
    return Localizations.of(context, CGQLocalizations);
  }
}
