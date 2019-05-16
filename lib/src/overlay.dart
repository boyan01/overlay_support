import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

///progress : from 0 - 1
typedef Widget AnimatedOverlayWidgetBuilder(
    BuildContext context, double progress);

///basic api to show overlay widget
///
///[duration] the overlay display duration , overlay will auto dismiss after [duration]
///if null , will be set to [kNotificationDuration]
///if zero , will not auto dismiss in the future
///
NotificationEntry showOverlay(
  BuildContext context,
  AnimatedOverlayWidgetBuilder builder, {
  Curve curve,
  Duration duration,
}) {
  duration ??= kNotificationDuration;
  final autoDismiss = duration != Duration.zero;

  GlobalKey<AnimatedOverlayState> key = GlobalKey();

  final entry = OverlayEntry(builder: (context) {
    return AnimatedOverlay(
      key: key,
      builder: builder,
      curve: curve,
    );
  });

  NotificationEntry notification = NotificationEntry(entry, key);

  final OverlayState overlay = context.rootAncestorStateOfType(
      const TypeMatcher<OverlayState>());
  assert(overlay != null, "can not find OverlayState");
  overlay.insert(entry);

  if (autoDismiss) {
    Future.delayed(duration + kNotificationSlideDuration).whenComplete(() {
      notification.dismiss();
    });
  }
  return notification;
}

class AnimatedOverlay extends StatefulWidget {
  final Duration animationDuration;

  final AnimatedOverlayWidgetBuilder builder;

  final Curve curve;

  AnimatedOverlay(
      {@required Key key,
      Duration animationDuration,
      Curve curve,
      @required this.builder})
      : animationDuration = animationDuration ?? kNotificationSlideDuration,
        curve = curve ?? Curves.easeInOut,
        assert(animationDuration == null || animationDuration >= Duration.zero),
        super(key: key);

  @override
  AnimatedOverlayState createState() => AnimatedOverlayState();
}

class AnimatedOverlayState extends State<AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  TickerFuture _forwarding;

  void show() {
    _forwarding = _controller.forward(from: _controller.value);
  }

  Future hide({bool waitShow = true}) async {
    if (waitShow) {
      if (_forwarding == null) {
        show();
      }
      await _forwarding;
    }

    final completer = Completer();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        completer.complete();
      }
    });
    _controller.reverse(from: _controller.value);
    return await completer.future;
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        debugLabel: 'AnimatedOverlayShowHideAnimation');
    super.initState();
    show();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return widget.builder(
              context, widget.curve.transform(_controller.value));
        });
  }
}
