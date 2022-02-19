import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

/// Popup a notification at the top of screen.
///
/// [duration] the notification display duration , overlay will auto dismiss after [duration].
/// if null , will be set to [kNotificationDuration].
/// if zero , will not auto dismiss in the future.
///
/// [position] the position of notification, default is [NotificationPosition.top],
/// can be [NotificationPosition.top] or [NotificationPosition.bottom].
///
OverlaySupportEntry showOverlayNotification(
  WidgetBuilder builder, {
  Duration? duration,
  Key? key,
  NotificationPosition position = NotificationPosition.top,
  BuildContext? context,
}) {
  duration ??= kNotificationDuration;
  return showOverlay(
    (context, t) {
      var alignment = MainAxisAlignment.start;
      if (position == NotificationPosition.bottom) {
        alignment = MainAxisAlignment.end;
      }
      return Column(
        mainAxisAlignment: alignment,
        children: <Widget>[
          position == NotificationPosition.top
              ? TopSlideNotification(builder: builder, progress: t)
              : BottomSlideNotification(builder: builder, progress: t)
        ],
      );
    },
    duration: duration,
    key: key,
    context: context,
  );
}

///
/// Show a simple notification above the top of window.
///
OverlaySupportEntry showSimpleNotification(
  Widget content, {
  /**
   * See more [ListTile.leading].
   */
  Widget? leading,
  /**
   * See more [ListTile.subtitle].
   */
  Widget? subtitle,
  /**
   * See more [ListTile.trailing].
   */
  Widget? trailing,
  /**
   * See more [ListTile.contentPadding].
   */
  EdgeInsetsGeometry? contentPadding,
  /**
   * The background color for notification, default to [ColorScheme.secondary].
   */
  Color? background,
  /**
   * See more [ListTileTheme.textColor],[ListTileTheme.iconColor].
   */
  Color? foreground,
  /**
   * The elevation of notification, see more [Material.elevation].
   */
  double elevation = 16,
  Duration? duration,
  Key? key,
  /**
   * True to auto hide after duration [kNotificationDuration].
   */
  bool autoDismiss = true,
  /**
   * Support left/right to dismiss notification.
   */
  @Deprecated('use slideDismissDirection instead') bool slideDismiss = false,
  /**
   * The position of notification, default is [NotificationPosition.top],
   */
  NotificationPosition position = NotificationPosition.top,
  BuildContext? context,
  /**
   * The direction in which the notification can be dismissed.
   */
  DismissDirection? slideDismissDirection,
}) {
  final dismissDirection = slideDismissDirection ??
      (slideDismiss ? DismissDirection.horizontal : DismissDirection.none);
  final entry = showOverlayNotification(
    (context) {
      return SlideDismissible(
        direction: dismissDirection,
        key: ValueKey(key),
        child: Material(
          color: background ?? Theme.of(context).colorScheme.secondary,
          elevation: elevation,
          child: SafeArea(
              bottom: position == NotificationPosition.bottom,
              top: position == NotificationPosition.top,
              child: ListTileTheme(
                textColor:
                    foreground ?? Theme.of(context).colorScheme.onSecondary,
                iconColor:
                    foreground ?? Theme.of(context).colorScheme.onSecondary,
                child: ListTile(
                  leading: leading,
                  title: content,
                  subtitle: subtitle,
                  trailing: trailing,
                  contentPadding: contentPadding,
                ),
              )),
        ),
      );
    },
    duration: autoDismiss ? duration : Duration.zero,
    key: key,
    position: position,
    context: context,
  );
  return entry;
}
