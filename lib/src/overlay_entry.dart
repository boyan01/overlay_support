part of 'overlay.dart';

class OverlaySupportEntry extends NotificationEntry {
  static final _entries = <_OverlayKey, OverlaySupportEntry>{};

  static OverlaySupportEntry of(BuildContext context) {
    final key = _KeyedOverlay.of(context);
    assert(key != null, 'can not find _OverlayKey');
    return null;
  }

  OverlaySupportEntry(_OverlayKey key, OverlayEntry entry) : super(entry, key) {
    assert(() {
      if (_entries[key] != null) {
        throw FlutterError(
            'there still a OverlaySupportEntry associactd with $key');
      }
      return true;
    }());
    _entries[key] = this;
    dismissEnd.future.whenComplete(() {
      _entries.remove(key);
    });
  }
}

@Deprecated('use OverlaySupportEntry instead , will be remove in 1.0')
class NotificationEntry {
  final OverlayEntry _entry;
  final _OverlayKey _key;

  NotificationEntry(this._entry, this._key);

  bool _dismissed = false;

  ///to known when notification has been dismissed
  Completer dismissEnd = Completer();

  ///to known when notification hide
  Completer dismissStart = Completer();

  GlobalKey<_AnimatedOverlayState> get _stateKey => _key._globalKey;

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry after [_AnimatedOverlayState.hide]
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
      if (_stateKey.currentState != null) {
        _stateKey.currentState.hide().whenComplete(() {
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
