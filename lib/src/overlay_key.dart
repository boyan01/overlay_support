part of 'overlay.dart';

///A widget that builds its child.
///the same as [KeyedSubtree]
class _KeyedOverlay extends StatelessWidget {
  static _OverlayKey of(BuildContext context) {
    _KeyedOverlay widget = context.ancestorWidgetOfExactType(_KeyedOverlay);
    assert(widget != null,
        'can not find _KeyedOverlay, maybe you call from a wrong context');
    return widget.key;
  }

  final Widget child;

  const _KeyedOverlay({_OverlayKey key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

///[showOverlay] with this key will be rejected if a overlay with the same key is being showing
///
/// for example
/// ```dart
/// final rejectKey = RejectKey('simple');
///
/// //popup a simple message on top of screen
/// showSimpleNotification(context, Text('reject example'), rejectKey);
///
/// //when previous notification is showing, popup again whit this key
/// //this notification will be rejected.
/// showSimpleNotification(context, Text('reject example 2'), rejectKey);
///
/// ```
class RejectKey extends ValueKey<Key> {
  RejectKey(Key value) : super(value);

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final RejectKey typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, value);
}

class _OverlayKey extends ValueKey<Key> {
  _OverlayKey(Key key) : super(key ?? UniqueKey());
}
