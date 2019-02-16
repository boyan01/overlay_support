library overlay_support;

export 'src/notification/overlay_notification.dart';

export 'src/overlay_entry.dart';

export 'src/toast/overlay_toast.dart';

///The length of time the notification is fully displayed
Duration kNotificationDuration = const Duration(milliseconds: 2000);

///Notification display or hidden animation duration
Duration kNotificationSlideDuration = const Duration(milliseconds: 300);
