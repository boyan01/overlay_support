part of 'overlay.dart';

///
/// [OverlaySupportEntry] represent a overlay popup by [showOverlay]
///
/// provide function [dismiss] to dismiss a Notification/Overlay
///
class OverlaySupportEntry extends NotificationEntry {
  static final _entries = <_OverlayKey, OverlaySupportEntry>{};
  static final _entriesGlobal = <GlobalKey, OverlaySupportEntry>{};

  static OverlaySupportEntry of(BuildContext context,
      {Widget requireForDebug}) {
    final animatedOverlay = context.ancestorWidgetOfExactType(_AnimatedOverlay);
    assert(() {
      if (animatedOverlay == null && requireForDebug != null) {
        throw FlutterError('No _AnimatedOverlay widget found.\n'
            '${requireForDebug.runtimeType} require an OverlaySupportEntry for corrent operation\n'
            'is that you called this method from the right scope? ');
      }
      return true;
    }());

    final key = animatedOverlay.key;
    assert(key is GlobalKey);

    return OverlaySupportEntry._entriesGlobal[key];
  }

  OverlaySupportEntry(_OverlayKey key, OverlayEntry entry,
      GlobalKey<_AnimatedOverlayState> stateKey)
      : super(entry, key, stateKey) {
    assert(() {
      if (_entries[key] != null) {
        throw FlutterError(
            'there still a OverlaySupportEntry associactd with $key');
      }
      return true;
    }());
    _entries[key] = this;
    _entriesGlobal[stateKey] = this;
  }
}

@Deprecated('use OverlaySupportEntry instead , will be remove in 1.0')
class NotificationEntry {
  final OverlayEntry _entry;
  final _OverlayKey _key;
  final GlobalKey<_AnimatedOverlayState> _stateKey;

  NotificationEntry(this._entry, this._key, this._stateKey);

  ///this overlay has been dismissed
  bool _dismissed = false;

  ///to known when notification has been dismissed
  final Completer _dismissedCompleter = Completer();

  Future get dismissed => _dismissedCompleter.future;

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry after [_AnimatedOverlayState.hide]
  void dismiss({bool animate = true}) {
    if (_dismissed) {
      //avoid duplicate call
      return;
    }
    _dismissed = true;
    OverlaySupportEntry._entries.remove(_key);
    if (!animate) {
      _dismissEntry();
      return;
    }

    void animateRemove() {
      if (_stateKey.currentState != null) {
        _stateKey.currentState.hide().whenComplete(() {
          _dismissEntry();
        });
      } else {
        //we need show animation before remove this entry
        //so need ensure entry has been inserted into screen
        WidgetsBinding.instance.scheduleFrameCallback((_) => animateRemove());
      }
    }

    animateRemove();
  }

  void _dismissEntry() {
    OverlaySupportEntry._entriesGlobal.remove(_stateKey);
    _entry.remove();
    _dismissedCompleter.complete();
  }
}
