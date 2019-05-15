import 'package:flutter/widgets.dart';
import 'package:overlay_support/src/overlay.dart';

class NotificationEntry {
  final OverlayEntry _entry;
  final GlobalKey<AnimatedOverlayState> _key;

  NotificationEntry(this._entry, this._key);

  bool _dismissed = false;

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry with animation of [AnimatedOverlayState.hide]
  void dismiss({bool animate = true}) {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    if (!animate) {
      _entry.remove();
      return;
    }

    void animateRemove() {
      if (_key.currentState != null) {
        _key.currentState.hide().whenComplete(() {
          _entry.remove();
        });
      } else {
        //we need show animation before remove this entry
        //so need ensure entry has been inserted into screen
        WidgetsBinding.instance.scheduleFrameCallback((_) => animateRemove());
      }
    }

    animateRemove();
  }
}
