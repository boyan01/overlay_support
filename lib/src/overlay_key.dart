part of 'overlay.dart';

///A widget that builds its child.
///the same as [KeyedSubtree]
class _KeyedOverlay extends StatelessWidget {
  final Widget child;

  const _KeyedOverlay({_OverlayKey key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

///[showOverlay] with block other show with the same [ModalKey]
///
/// for example
/// ```dart
/// final modalKey = ModalKey('simple');
///
/// //popup a simple message on top of screen
/// showSimpleNotification(Text('modal example'), key: modalKey);
///
/// //when previous notification is showing, popup again whit this key
/// //this notification will be rejected.
/// showSimpleNotification(Text('modal example 2'), key: modalKey);
///
/// ```
class ModalKey<T> extends ValueKey<T> {
  ModalKey(T value) : super(value);

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final ModalKey<T> typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, value);
}

class _OverlayKey extends ValueKey<Key> {
  _OverlayKey(Key key) : super(key ?? UniqueKey());
}
