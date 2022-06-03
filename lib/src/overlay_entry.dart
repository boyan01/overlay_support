part of 'overlay.dart';

abstract class OverlaySupportEntry {
  factory OverlaySupportEntry._internal(
    OverlayEntry entry,
    Key key,
    GlobalKey<_AnimatedOverlayState> stateKey,
    OverlaySupportState overlaySupport,
  ) {
    return _OverlaySupportEntryImpl._(entry, key, stateKey, overlaySupport);
  }

  factory OverlaySupportEntry.empty() {
    return _OverlaySupportEntryEmpty();
  }

  /// Find OverlaySupportEntry by [context].
  ///
  /// The [context] should be the BuildContext which build a element in Notification.
  ///
  static OverlaySupportEntry? of(BuildContext context) {
    final animatedOverlay =
        context.findAncestorWidgetOfExactType<_AnimatedOverlay>();
    assert(() {
      if (animatedOverlay == null) {
        throw FlutterError('No KeyedOverlay widget found.\n'
            'The [context] should be the BuildContext which build a element in Notification.\n'
            'is that you called this method from the right scope? ');
      }
      return true;
    }());
    if (animatedOverlay == null) {
      return OverlaySupportEntry.empty();
    }
    return animatedOverlay.overlaySupportState
        .getEntry(key: animatedOverlay.overlayKey);
  }

  /// Dismiss the Overlay which associated with this entry.
  /// If [animate] is false, remove entry immediately.
  /// If [animate] is true, remove entry after [_AnimatedOverlayState.hide]
  void dismiss({bool animate = true});

  Future get dismissed;
}

/// [OverlaySupportEntry] represent a overlay popup by [showOverlay].
///
/// Provide function [dismiss] to dismiss a Notification/Overlay.
///
class _OverlaySupportEntryImpl implements OverlaySupportEntry {
  final OverlayEntry _entry;
  final Key _overlayKey;
  final GlobalKey<_AnimatedOverlayState> _stateKey;
  final OverlaySupportState _overlaySupport;

  _OverlaySupportEntryImpl._(
    this._entry,
    this._overlayKey,
    this._stateKey,
    this._overlaySupport,
  );

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
      // Remove this entry from overlaySupportState no matter it is animating or not.
      // because when the entry with the same key, we need to show it now.
      _overlaySupport.removeEntry(key: _overlayKey);
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
        _ambiguate(WidgetsBinding.instance)
            ?.scheduleFrameCallback((_) => animateRemove());
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

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;

class _OverlaySupportEntryEmpty implements OverlaySupportEntry {
  @override
  void dismiss({bool animate = true}) {}

  @override
  Future get dismissed => Future.value(null);
}
