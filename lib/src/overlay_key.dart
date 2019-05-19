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

class _OverlayKey extends ValueKey<Key> {
  final GlobalKey<_AnimatedOverlayState> _globalKey = GlobalKey();

  _OverlayKey(Key key) : super(key);
}
