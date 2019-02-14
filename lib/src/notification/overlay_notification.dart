import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/src/notification/notification.dart';

///The length of time the notification is fully displayed
Duration kNotificationDuration = const Duration(milliseconds: 2000);

///Notification display or hidden animation duration
Duration kNotificationSlideDuration = const Duration(milliseconds: 300);

typedef NotificationTapCallback = void Function(NotificationEntry entry);

/// popup a notification at the top of screen
///
/// [autoDismiss] true : dismiss after duration [kNotificationSlideDuration]
///               false: need manually close notification by [NotificationEntry#dismiss]
///
NotificationEntry showOverlayNotification(
    BuildContext context, WidgetBuilder builder,
    {bool autoDismiss = true}) {
  assert(autoDismiss != null);

  GlobalKey<OverlayNotificationState> key = GlobalKey();
  NotificationEntry notification;

  final entry = OverlayEntry(builder: (context) {
    return Column(
      children: <Widget>[
        OverlayNotification(
          key: key,
          builder: builder,
        )
      ],
    );
  });

  notification = NotificationEntry(entry, key);

  Overlay.of(context).insert(entry);

  if (autoDismiss) {
    Future.delayed(kNotificationDuration + kNotificationSlideDuration)
        .whenComplete(() {
      notification.dismiss();
    });
  }
  return notification;
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
  NotificationEntry entry;
  entry = showOverlayNotification(context, (context) {
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

class NotificationEntry {
  final OverlayEntry _entry;
  final GlobalKey<OverlayNotificationState> _key;

  NotificationEntry(this._entry, this._key);

  bool _dismissed = false;

  ///dismiss notification
  void dismiss({bool animate = true}) {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    if (!animate) {
      _entry.remove();
      return;
    }
    _key.currentState.hide().whenComplete(() {
      _entry.remove();
    });
  }
}
