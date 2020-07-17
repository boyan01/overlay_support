import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/notification/notification.dart';
import 'package:overlay_support/src/overlay.dart';

/// popup a notification at the top of screen
///
///[duration] the notification display duration , overlay will auto dismiss after [duration]
///if null , will be set to [kNotificationDuration]
///if zero , will not auto dismiss in the future
///
/// [position] the position of notification, default is [NotificationPosition.top],
/// can be [NotificationPosition.top] or [NotificationPosition.bottom]
///
OverlaySupportEntry showOverlayNotification(
  WidgetBuilder builder, {
  Duration duration,
  Key key,
  NotificationPosition position = NotificationPosition.top,
}) {
  if (duration == null) {
    duration = kNotificationDuration;
  }
  return showOverlay((context, t) {
    MainAxisAlignment alignment = MainAxisAlignment.start;
    if (position == NotificationPosition.bottom) alignment = MainAxisAlignment.end;
    return Column(
      mainAxisAlignment: alignment,
      children: <Widget>[
        position == NotificationPosition.top
            ? TopSlideNotification(builder: builder, progress: t)
            : BottomSlideNotification(builder: builder, progress: t)
      ],
    );
  }, duration: duration, key: key);
}

///
///show a simple notification above the top of window
///
///
/// [content] see more [ListTile.title]
/// [leading] see more [ListTile.leading]
/// [subtitle] see more [ListTile.subtitle]
/// [trailing] see more [ListTile.trailing]
/// [contentPadding] see more [ListTile.contentPadding]
///
/// [background] the background color for notification , default is [ThemeData.accentColor]
/// [foreground] see more [ListTileTheme.textColor],[ListTileTheme.iconColor]
///
/// [elevation] the elevation of notification, see more [Material.elevation]
/// [autoDismiss] true to auto hide after duration [kNotificationDuration]
/// [slideDismiss] support left/right to dismiss notification
/// [position] the position of notification, default is [NotificationPosition.top],
/// can be [NotificationPosition.top] or [NotificationPosition.bottom]
///
OverlaySupportEntry showSimpleNotification(Widget content,
    {Widget leading,
    Widget subtitle,
    Widget trailing,
    EdgeInsetsGeometry contentPadding,
    Color background,
    Color foreground,
    double elevation = 16,
    Duration duration,
    Key key,
    bool autoDismiss = true,
    bool slideDismiss = false,
    NotificationPosition position = NotificationPosition.top}) {
  final entry = showOverlayNotification((context) {
    return SlideDismissible(
      enable: slideDismiss,
      key: ValueKey(key),
      child: Material(
        color: background ?? Theme.of(context)?.accentColor,
        elevation: elevation,
        child: SafeArea(
            bottom: position == NotificationPosition.bottom,
            top: position == NotificationPosition.top,
            child: ListTileTheme(
              textColor: foreground ?? Theme.of(context)?.accentTextTheme?.title?.color,
              iconColor: foreground ?? Theme.of(context)?.accentTextTheme?.title?.color,
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
      position: position);
  return entry;
}
