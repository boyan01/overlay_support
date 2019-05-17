import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:overlay_support/src/overlay.dart';

class NotificationEntry {
  final OverlayEntry _entry;
  final GlobalKey<AnimatedOverlayState> _key;

  NotificationEntry(this._entry, this._key);

  bool _dismissed = false;

  ///to known when notification has been dismissed
  Completer dismissEnd = Completer();

  ///to known when notification hide
  Completer dismissStart = Completer();

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry after [AnimatedOverlayState.hide]
  void dismiss({bool animate = true}) {
    if (_dismissed) {
      //avoid duplicate call
      return;
    }
    _dismissed = true;
    dismissStart.complete();
    if (!animate) {
      _entry.remove();
      dismissEnd.complete();
      return;
    }

    void animateRemove() {
      if (_key.currentState != null) {
        _key.currentState.hide().whenComplete(() {
          _entry.remove();
          dismissEnd.complete();
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
