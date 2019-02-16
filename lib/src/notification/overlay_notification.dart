import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/notification/notification.dart';
import 'package:overlay_support/src/overlay.dart';

/// popup a notification at the top of screen
///
/// [autoDismiss] true : dismiss after duration [kNotificationSlideDuration]
///               false: need manually close notification by [NotificationEntry#dismiss]
///
NotificationEntry showOverlayNotification(
    BuildContext context, WidgetBuilder builder,
    {bool autoDismiss = true}) {
  return showOverlay(context, (context, t) {
    return Column(
      children: <Widget>[
        TopSlideNotification(builder: builder, progress: t),
      ],
    );
  }, autoDismiss: autoDismiss);
}

///show a simple notification above the top of window
NotificationEntry showSimpleNotification(BuildContext context, Widget content,
    {Widget leading,
    Widget subtitle,
    Widget trailing,
    EdgeInsetsGeometry contentPadding,
    Color background,
    Color foreground,
    bool autoDismiss = true}) {
  final entry = showOverlayNotification(context, (context) {
    return Material(
      color: background ?? Theme.of(context)?.accentColor,
      elevation: 16,
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
  }, autoDismiss: autoDismiss);
  return entry;
}
