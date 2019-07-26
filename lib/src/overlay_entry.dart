part of 'overlay.dart';

///
/// [OverlaySupportEntry] represent a overlay popup by [showOverlay]
///
/// provide function [dismiss] to dismiss a Notification/Overlay
///
class OverlaySupportEntry {
  static final _entries = HashMap<_OverlayKey, OverlaySupportEntry>();
  static final _entriesGlobal = HashMap<GlobalKey, OverlaySupportEntry>();

  final OverlayEntry _entry;
  final _OverlayKey _key;
  final GlobalKey<_AnimatedOverlayState> _stateKey;

  static OverlaySupportEntry of(BuildContext context, {Widget requireForDebug}) {
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

  OverlaySupportEntry(this._entry, this._key, this._stateKey) {
    assert(() {
      if (_entries[_key] != null) {
        throw FlutterError('there still a OverlaySupportEntry associactd with $_key');
      }
      return true;
    }());
    _entries[_key] = this;
    _entriesGlobal[_stateKey] = this;
  }

  factory OverlaySupportEntry.empty() {
    return _OverlaySupportEntryEmpty();
  }

  ///to known when notification has been dismissed
  final Completer _dismissedCompleter = Completer();

  Future get dismissed => _dismissedCompleter.future;

  // OverlayEntry has been scheduled to dismiss,
  // indicate OverlayEntry is hiding or already remove from Overlay
  bool _dismissScheduled = false;

  // OverlayEntry has been removed from Overlay
  bool _dismissed = false;

  ///dismiss notification
  ///animate = false , remove entry immediately
  ///animate = true, remove entry after [_AnimatedOverlayState.hide]
  void dismiss({bool animate = true}) {
    if (_dismissed || (_dismissScheduled && animate)) {
      return;
    }
    if (!_dismissScheduled) {
      // Remove this from _entries, be seems _key'overlay entry is scheduled to dismiss
      // so we can popup another overlay entry with the same key
      _entries.remove(_key);
    }
    _dismissScheduled = true;

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

  //dismiss entry immediately and remove it from screen
  void _dismissEntry() {
    if (_dismissed) {
      //already removed from screen
      return;
    }
    _dismissed = true;
    _entriesGlobal.remove(_stateKey);
    _entry.remove();
    _dismissedCompleter.complete();
  }
}

class _OverlaySupportEntryEmpty implements OverlaySupportEntry {
  @override
  void _dismissEntry() {}

  @override
  Completer get _dismissedCompleter => null;

  @override
  OverlayEntry get _entry => null;

  @override
  _OverlayKey get _key => null;

  @override
  GlobalKey<_AnimatedOverlayState> get _stateKey => null;

  @override
  void dismiss({bool animate = true}) {}

  @override
  Future get dismissed => Future.value(null);

  @override
  bool _dismissScheduled = true;

  @override
  bool _dismissed = true;
}
