library overlay_support;

export 'src/notification/overlay_notification.dart';
export 'src/notification/notification.dart';
export 'src/overlay.dart';
export 'src/toast/toast.dart';
export 'src/theme.dart';

///The length of time the notification is fully displayed
Duration kNotificationDuration = const Duration(milliseconds: 2000);

///Notification display or hidden animation duration
Duration kNotificationSlideDuration = const Duration(milliseconds: 300);
