import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

/// A notification show in front of screen and shown at the top.
class TopSlideNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final Animation<double> animation;

  const TopSlideNotification({Key key, @required this.builder, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
          .chain(CurveTween(curve: Curves.ease))
          .animate(animation),
      child: builder(context),
    );
  }
}

/// a notification show in front of screen and shown at the bottom
class BottomSlideNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final Animation<double> animation;

  const BottomSlideNotification({Key key, @required this.builder, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
          .chain(CurveTween(curve: Curves.ease))
          .animate(animation),
      child: builder(context),
    );
  }
}

/// Can be dismiss by left or right slide
class SlideDismissible extends StatelessWidget {
  final Widget child;

  final bool enable;

  const SlideDismissible({
    @required Key key,
    @required this.child,
    @required this.enable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enable) return child;
    return Dismissible(
      child: child,
      key: key,
      onDismissed: (direction) {
        OverlaySupportEntry.of(context, requireForDebug: this).dismiss(animate: false);
      },
    );
  }
}
