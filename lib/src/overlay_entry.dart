part of 'overlay.dart';

///
/// [OverlaySupportEntry] represent a overlay popup by [showOverlay]
///
/// provide function [dismiss] to dismiss a Notification/Overlay
///
class OverlaySupportEntry extends NotificationEntry {
  static final _entries = <_OverlayKey, OverlaySupportEntry>{};

  static OverlaySupportEntry of(BuildContext context,
      {Widget requireForDebug}) {
    final key = _KeyedOverlay.of(context);
    assert(() {
      if (key == null && requireForDebug != null) {
        throw FlutterError('No _KeyedOverlay widget found.\n'
            '${requireForDebug.runtimeType} require an _KeyedOverlay widget ancestor for correct operation.\n'
            'if can only get OverlaySupportEntry in scope such as showOverlay() ');
      }
      return true;
    }());
    return OverlaySupportEntry?._entries[key];
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
  }
}

@Deprecated('use OverlaySupportEntry instead , will be remove in 1.0')
class NotificationEntry {
  final OverlayEntry _entry;
  final _OverlayKey _key;
  final GlobalKey<_AnimatedOverlayState> _stateKey;

  NotificationEntry(this._entry, this._key, this._stateKey);

  bool _dismissed = false;

  ///to known when notification has been dismissed
  final Completer _dismissedCompleter = Completer();

  Future get dismissed => _dismissedCompleter.future;

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry after [_AnimatedOverlayState.hide]
  void dismiss({bool animate = true}) {
    if (_dismissedCompleter.isCompleted) {
      //avoid duplicate call
      return;
    }
    if (!animate) {
      _dismissedCompleter.complete();
      _dismissEntry();
      return;
    }

    void animateRemove() {
      if (_stateKey.currentState != null) {
        _stateKey.currentState.hide();
      } else {
        //we need show animation before remove this entry
        //so need ensure entry has been inserted into screen
        WidgetsBinding.instance.scheduleFrameCallback((_) => animateRemove());
      }
    }

    animateRemove();
  }

  void _dismissEntry() {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    OverlaySupportEntry._entries.remove(_key);
    _entry.remove();
  }
}
