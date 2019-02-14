import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/src/notification/overlay_notification.dart';

/// a notification show in front of screen and shown at the top
class OverlayNotification extends StatefulWidget {
  OverlayNotification({key: Key, this.builder, this.animationDuration})
      : assert(animationDuration == null || animationDuration >= Duration.zero),
        super(key: key);

  ///build notification content
  final WidgetBuilder builder;

  ///show and hide animation duration
  ///null will be set the default [kNotificationSlideDuration]
  final Duration animationDuration;

  @override
  OverlayNotificationState createState() {
    return new OverlayNotificationState();
  }
}

class OverlayNotificationState extends State<OverlayNotification>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<Offset> position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ?? kNotificationSlideDuration,
    );
    position = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0))
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    show();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: position,
      child: widget.builder(context),
    );
  }

  void show() {
    _controller.forward(from: _controller.value);
  }

  Future hide() {
    final completer = Completer();
    _controller.reverse(from: _controller.value);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        completer.complete();
      }
    });
    return completer.future
      /*set time out more 50 milliseconds*/
      ..timeout(widget.animationDuration ??
          kNotificationSlideDuration + const Duration(milliseconds: 50));
  }
}
