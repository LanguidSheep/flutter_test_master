import 'package:flutter/material.dart';
import 'package:flutter_test_master/entity/Event.dart';
import 'package:flutter_test_master/entity/RepoCommit.dart';
import 'package:flutter_test_master/utils/cgq_style.dart';
import 'package:flutter_test_master/utils/common_utils.dart';
import 'package:flutter_test_master/utils/event_utils.dart';
import 'package:flutter_test_master/entity/Notification.dart' as Model;
import 'package:flutter_test_master/utils/navigator_utils.dart';

import 'cgq_card_item.dart';
import 'cgq_user_icon_widget.dart';

/// event_item
/// Created by Chen_Mr on 2019/7/2.

class EventItem extends StatelessWidget {
  final EventViewModel eventViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  EventItem(this.eventViewModel, {this.onPressed, this.needImage = true})
      : super();

  @override
  Widget build(BuildContext context) {
    Widget des = (eventViewModel.actionDes == null ||
            eventViewModel.actionDes.length == 0)
        ? new Container()
        : new Container(
            child: new Text(
              eventViewModel.actionDes,
              style: CGQTextsConstant.smallSubText,
              maxLines: 3,
            ),
            margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
            alignment: Alignment.topLeft,
          );

    Widget userImage = (needImage)
        ? new CGQUserIconWidget(
            padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 0.0),
            width: 30.0,
            height: 30.0,
            image: eventViewModel.actionUserPic,
            onPressed: () {
              NavigatorUtils.goPerson(context, eventViewModel.actionUser);
            },
          )
        : new Container();
    return new Container(
      child: new CGQCardItem(
        child: new FlatButton(
            onPressed: onPressed,
            child: new Padding(
              padding: new EdgeInsets.only(
                  left: 0.0, top: 10.0, right: 0.0, bottom: 10.0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      userImage,
                      new Expanded(
                        child: new Text(
                          eventViewModel.actionUser,
                          style: CGQTextsConstant.smallTextBold,
                        ),
                      ),
                      new Text(
                        eventViewModel.actionTime,
                        style: CGQTextsConstant.smallSubText,
                      ),
                    ],
                  ),
                  new Container(
                    child: new Text(
                      eventViewModel.actionTarget,
                      style: CGQTextsConstant.smallTextBold,
                    ),
                    margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                    alignment: Alignment.topLeft,
                  ),
                  des,
                ],
              ),
            )),
      ),
    );
  }
}

class EventViewModel {
  String actionUser;
  String actionUserPic;
  String actionDes;
  String actionTime;
  String actionTarget;

  EventViewModel.fromEventMap(Event event) {
    actionTime = CommonUtils.getNewsTimeStr(event.createdAt);
    actionUser = event.actor.login;
    actionUserPic = event.actor.avatar_url;
    var other = EventUtils.getActionAndDes(event);
    actionDes = other["des"];
    actionTarget = other["actionStr"];
  }

  EventViewModel.fromCommitMap(RepoCommit eventMap) {
    actionTime = CommonUtils.getNewsTimeStr(eventMap.commit.committer.date);
    actionUser = eventMap.commit.committer.name;
    actionDes = "sha:" + eventMap.sha;
    actionTarget = eventMap.commit.message;
  }

  EventViewModel.fromNotify(BuildContext context, Model.Notification eventMap) {
    actionTime = CommonUtils.getNewsTimeStr(eventMap.updateAt);
    actionUser = eventMap.repository.fullName;
    String type = eventMap.subject.type;
    String status = eventMap.unread
        ? CommonUtils.getLocale(context).notify_unread
        : CommonUtils.getLocale(context).notify_readed;
    actionDes = eventMap.reason +
        "${CommonUtils.getLocale(context).notify_type}：$type，${CommonUtils.getLocale(context).notify_status}：$status";
    actionTarget = eventMap.subject.title;
  }
}
