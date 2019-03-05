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
NotificationEntry showOverlayNotification(
  BuildContext context,
  WidgetBuilder builder, {
  @Deprecated('use duration insted') bool autoDismiss = true,
  Duration duration,
}) {
  if (duration == null) {
    duration = autoDismiss ? kNotificationDuration : Duration.zero;
  }
  return showOverlay(context, (context, t) {
    return Column(
      children: <Widget>[
        TopSlideNotification(builder: builder, progress: t),
      ],
    );
  }, duration: duration);
}

///show a simple notification above the top of window
NotificationEntry showSimpleNotification(BuildContext context, Widget content,
    {Widget leading,
    Widget subtitle,
    Widget trailing,
    EdgeInsetsGeometry contentPadding,
    Color background,
    Color foreground,
    double elevation = 16,
    bool autoDismiss = true}) {
  final entry = showOverlayNotification(context, (context) {
    return Material(
      color: background ?? Theme.of(context)?.accentColor,
      elevation: elevation,
      child: SafeArea(
          child: ListTileTheme(
        textColor:
            foreground ?? Theme.of(context)?.accentTextTheme?.title?.color,
        iconColor:
            foreground ?? Theme.of(context)?.accentTextTheme?.title?.color,
        child: ListTile(
          leading: leading,
          title: content,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: contentPadding,
        ),
      )),
    );
  }, duration: autoDismiss ? null : Duration.zero);
  return entry;
}
