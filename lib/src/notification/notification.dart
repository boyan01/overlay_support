import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

/// A notification show in front of screen and shown at the top.
class TopSlideNotification extends StatelessWidget {
  /// Which used to build notification content.
  final WidgetBuilder builder;

  final double progress;

  const TopSlideNotification(
      {Key? key, required this.builder, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation:
          Offset.lerp(const Offset(0, -1), const Offset(0, 0), progress)!,
      child: builder(context),
    );
  }
}

/// a notification show in front of screen and shown at the bottom
class BottomSlideNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final double progress;

  const BottomSlideNotification(
      {Key? key, required this.builder, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation:
          Offset.lerp(const Offset(0, 1), const Offset(0, 0), progress)!,
      child: builder(context),
    );
  }
}

/// Can be dismiss by left or right slide.
class SlideDismissible extends StatelessWidget {
  final Widget child;

  final DismissDirection direction;

  SlideDismissible({
    Key? key,
    required this.child,
    @Deprecated('use directions instead.') bool enable = true,
    DismissDirection? direction,
  })  : direction = direction ??
            (enable ? DismissDirection.horizontal : DismissDirection.none),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: direction,
      onDismissed: (direction) {
        OverlaySupportEntry.of(context)!.dismiss(animate: false);
      },
      child: child,
    );
  }
}

/// Indicates if notification is going to show at the [top] or at the [bottom].
enum NotificationPosition { top, bottom }
