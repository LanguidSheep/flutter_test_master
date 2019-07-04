import 'package:flutter/material.dart';

/// cgq_style: 一些常量的设定[颜色值、图片值、文本样式值]
///
/// Created by Chen_Mr on 2019/6/14.

class CGQColorsConstant {

  static const String primaryValueString = "#24292E";

  static const int primaryValue = 0xFF24292E;
  static const int primaryDarkValue = 0xFF121917;
  static const int primaryLightValue = 0xFF42464b;
  static const int mainTextColor = primaryDarkValue;

  static const int white = 0xFFFFFFFF;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textWhite = 0xFFFFFFFF;
  static const int subTextColor = 0xff959595;
  static const int miWhite = 0xffececec;
  static const int actionBlue = 0xff267aff;
  static const int subLightTextColor = 0xffc4c4c4;

  static const int mainBackgroundColor = miWhite;

  static const int textColorWhite = white;

  static const MaterialColor primarySwatch = const MaterialColor(
    primaryValue,
    const <int, Color>{
      50: const Color(primaryLightValue),
      100: const Color(primaryLightValue),
      200: const Color(primaryLightValue),
      300: const Color(primaryLightValue),
      400: const Color(primaryLightValue),
      500: const Color(primaryValue),
      600: const Color(primaryDarkValue),
      700: const Color(primaryDarkValue),
      800: const Color(primaryDarkValue),
      900: const Color(primaryDarkValue),
    },
  );
}

class CGQTextsConstant {

  // todo 修改github地址
  static const String app_default_share_url = "https://github.com/CarGuo/GSYGithubAppFlutter";


  static const lagerTextSize = 30.0;
  static const bigTextSize = 23.0;
  static const normalTextSize = 18.0;
  static const smallTextSize = 14.0;
  static const middleTextWhiteSize = 16.0;
  static const minTextSize = 12.0;

  static const minText = TextStyle(
    color: Color(CGQColorsConstant.subLightTextColor),
    fontSize: minTextSize,
  );

  static const normalText = TextStyle(
    color: Color(CGQColorsConstant.mainTextColor),
    fontSize: normalTextSize,
  );

  static const middleText = TextStyle(
    color: Color(CGQColorsConstant.mainTextColor),
    fontSize: middleTextWhiteSize,
  );

  static const middleTextWhite = TextStyle(
    color: Color(CGQColorsConstant.textColorWhite),
    fontSize: middleTextWhiteSize,
  );

  static const normalTextBold = TextStyle(
    color: Color(CGQColorsConstant.mainTextColor),
    fontSize: normalTextSize,
    fontWeight: FontWeight.bold,
  );

  static const smallActionLightText = TextStyle(
    color: Color(CGQColorsConstant.actionBlue),
    fontSize: smallTextSize,
  );

  static const middleSubText = TextStyle(
    color: Color(CGQColorsConstant.subTextColor),
    fontSize: middleTextWhiteSize,
  );

  static const normalSubText = TextStyle(
    color: Color(CGQColorsConstant.subTextColor),
    fontSize: normalTextSize,
  );

  static const normalTextWhite = TextStyle(
    color: Color(CGQColorsConstant.textColorWhite),
    fontSize: normalTextSize,
  );

  static const largeTextWhite = TextStyle(
    color: Color(CGQColorsConstant.textColorWhite),
    fontSize: bigTextSize,
  );

  static const normalTextLight = TextStyle(
    color: Color(CGQColorsConstant.primaryLightValue),
    fontSize: normalTextSize,
  );

  static const smallSubText = TextStyle(
    color: Color(CGQColorsConstant.subTextColor),
    fontSize: smallTextSize,
  );

  static const smallSubLightText = TextStyle(
    color: Color(CGQColorsConstant.subLightTextColor),
    fontSize: smallTextSize,
  );

  static const smallTextBold = TextStyle(
    color: Color(CGQColorsConstant.mainTextColor),
    fontSize: smallTextSize,
    fontWeight: FontWeight.bold,
  );

  static const middleSubLightText = TextStyle(
    color: Color(CGQColorsConstant.subLightTextColor),
    fontSize: middleTextWhiteSize,
  );

  static const largeTextWhiteBold = TextStyle(
    color: Color(CGQColorsConstant.textColorWhite),
    fontSize: bigTextSize,
    fontWeight: FontWeight.bold,
  );
}

class CGQIConsConstant {
  static const String FONT_FAMILY = 'aliIconFont';

  static const String DEFAULT_USER_ICON = 'static/images/logo.png';
  static const String DEFAULT_IMAGE = 'static/images/default_img.png';
  static const String DEFAULT_REMOTE_PIC = 'https://raw.githubusercontent.com/CarGuo/GSYGithubAppFlutter/master/static/images/logo.png';

  static const IconData MORE = const IconData(0xe674, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData SEARCH = const IconData(0xe61c, fontFamily: CGQIConsConstant.FONT_FAMILY);


  static const IconData MAIN_DT =
      const IconData(0xe684, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData MAIN_QS =
      const IconData(0xe818, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData MAIN_MY =
      const IconData(0xe6d0, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData MAIN_SEARCH =
      const IconData(0xe61c, fontFamily: CGQIConsConstant.FONT_FAMILY);

  static const IconData LOGIN_USER =
      const IconData(0xe666, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData LOGIN_PW =
      const IconData(0xe60e, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData INPUT_DELETE_ICON =
      const IconData(0xe642, fontFamily: CGQIConsConstant.FONT_FAMILY);

  static const IconData REPOS_ITEM_USER = const IconData(0xe63e, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData REPOS_ITEM_STAR = const IconData(0xe643, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData REPOS_ITEM_FORK = const IconData(0xe67e, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData REPOS_ITEM_ISSUE = const IconData(0xe661, fontFamily: CGQIConsConstant.FONT_FAMILY);

  static const IconData USER_ITEM_COMPANY = const IconData(0xe63e, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData USER_ITEM_LOCATION = const IconData(0xe7e6, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData USER_ITEM_LINK = const IconData(0xe670, fontFamily: CGQIConsConstant.FONT_FAMILY);
  static const IconData USER_NOTIFY = const IconData(0xe600, fontFamily: CGQIConsConstant.FONT_FAMILY);


  static const IconData ISSUE_EDIT_H1 = Icons.filter_1;
  static const IconData ISSUE_EDIT_H2 = Icons.filter_2;
  static const IconData ISSUE_EDIT_H3 = Icons.filter_3;
  static const IconData ISSUE_EDIT_BOLD = Icons.format_bold;
  static const IconData ISSUE_EDIT_ITALIC = Icons.format_italic;
  static const IconData ISSUE_EDIT_QUOTE = Icons.format_quote;
  static const IconData ISSUE_EDIT_CODE = Icons.format_shapes;
  static const IconData ISSUE_EDIT_LINK = Icons.insert_link;
}
