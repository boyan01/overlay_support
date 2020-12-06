part of 'overlay.dart';

abstract class OverlaySupportEntry {
  factory OverlaySupportEntry.create(OverlayEntry entry, _OverlayKey key, GlobalKey<_AnimatedOverlayState> stateKey) {
    return _OverlaySupportEntryImpl._(entry, key, stateKey);
  }

  factory OverlaySupportEntry.empty() {
    return _OverlaySupportEntryEmpty();
  }

  /// Find OverlaySupportEntry by [context].
  ///
  /// The [context] should be the BuildContext which build a element in Notification.
  ///
  static OverlaySupportEntry? of(BuildContext context) {
    final animatedOverlay = context.findAncestorWidgetOfExactType<_KeyedOverlay>();
    assert(() {
      if (animatedOverlay == null) {
        throw FlutterError('No _KeyedOverlay widget found.\n'
            'The [context] should be the BuildContext which build a element in Notification.\n'
            'is that you called this method from the right scope? ');
      }
      return true;
    }());

    final key = animatedOverlay?.key;
    assert(key is _OverlayKey);

    return _overlayEntry(key: key as _OverlayKey);
  }

  static OverlaySupportEntry? _overlayEntry({required _OverlayKey key}) {
    return _OverlaySupportEntryImpl._entries[key];
  }

  /// Dismiss the Overlay which associated with this entry.
  /// If [animate] is false , remove entry immediately.
  /// If [animate] is true, remove entry after [_AnimatedOverlayState.hide]
  void dismiss({bool animate = true});

  Future get dismissed;
}

///
/// [OverlaySupportEntry] represent a overlay popup by [showOverlay].
///
/// Provide function [dismiss] to dismiss a Notification/Overlay.
///
class _OverlaySupportEntryImpl implements OverlaySupportEntry {
  static final _entries = HashMap<_OverlayKey, OverlaySupportEntry>();

  final OverlayEntry _entry;
  final _OverlayKey _key;
  final GlobalKey<_AnimatedOverlayState> _stateKey;

  _OverlaySupportEntryImpl._(this._entry, this._key, this._stateKey) {
    assert(() {
      if (_entries[_key] != null) {
        throw FlutterError('there still a OverlaySupportEntry associated with $_key');
      }
      return true;
    }());
    _entries[_key] = this;
  }

  // To known when notification has been dismissed.
  final Completer _dismissedCompleter = Completer();

  @override
  Future get dismissed => _dismissedCompleter.future;

  // OverlayEntry has been scheduled to dismiss,
  // indicate OverlayEntry is hiding or already remove from Overlay
  bool _dismissScheduled = false;

  // OverlayEntry has been removed from Overlay
  bool _dismissed = false;

  @override
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
        _stateKey.currentState!.hide().whenComplete(() {
          _dismissEntry();
        });
      } else {
        //we need show animation before remove this entry
        //so need ensure entry has been inserted into screen
        WidgetsBinding.instance?.scheduleFrameCallback((_) => animateRemove());
      }
    }

    animateRemove();
  }

  // dismiss entry immediately and remove it from screen
  void _dismissEntry() {
    if (_dismissed) {
      // already removed from screen
      return;
    }
    _dismissed = true;
    _entry.remove();
    _dismissedCompleter.complete();
  }
}

class _OverlaySupportEntryEmpty implements OverlaySupportEntry {
  @override
  void dismiss({bool animate = true}) {}

  @override
  Future get dismissed => Future.value(null);
}
