

import 'package:flutter_test_master/utils/flare/drat/animation/actor_animation.dart';
import 'package:flutter_test_master/utils/flare/drat/math/mat2d.dart';
import 'package:flutter_test_master/utils/flare/flutter/flare.dart';
import 'package:flutter_test_master/utils/flare/flutter/flare_controller.dart';

mixin CGQFlarePullController implements FlareController {
  ActorAnimation _pullAnimation;

  double pulledExtentFlare = 0;
  double _speed = 2.0;
  double _rockTime = 0.0;

  @override
  void initialize(FlutterActorArtboard artboard) {
    _pullAnimation = artboard.getAnimation("Earth Moving");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (getPlayAuto) {
      _rockTime += elapsed * _speed;
      _pullAnimation.apply(_rockTime % _pullAnimation.duration, artboard, 1.0);
      return true;
    }
    var pullExtent = (pulledExtentFlare > refreshTriggerPullDistance)
        ? pulledExtentFlare - refreshTriggerPullDistance
        : pulledExtentFlare;
    double animationPosition = pullExtent / refreshTriggerPullDistance;
    animationPosition *= animationPosition;
    _rockTime = _pullAnimation.duration * animationPosition;
    _pullAnimation.apply(_rockTime, artboard, 1.0);
    return true;
  }

  bool get getPlayAuto;

  double get refreshTriggerPullDistance => 140;
}
