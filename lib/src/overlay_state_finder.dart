import 'package:flutter/material.dart';

OverlayState? findOverlayState({BuildContext? context}) {
  if (context == null) {
    return _globalOverlayState;
  }
  return Navigator.of(context).overlay;
}

final GlobalKey<_OverlayFinderState> _keyFinder = GlobalKey(debugLabel: 'overlay_support');

OverlayState? get _globalOverlayState {
  final context = _keyFinder.currentContext;
  if (context == null) return null;

  NavigatorState? navigator;
  void visitor(Element element) {
    if (navigator != null) return;

    if (element.widget is Navigator) {
      navigator = (element as StatefulElement).state as NavigatorState?;
    } else {
      element.visitChildElements(visitor);
    }
  }

  context.visitChildElements(visitor);

  assert(navigator != null, '''It looks like you are not using Navigator in your app.
         
         do you wrapped you app widget like this?
         
         OverlaySupport(
           child: MaterialApp(
             title: 'Overlay Support Example',
             home: HomePage(),
           ),
         )
      
      ''');
  return navigator?.overlay;
}

/// Used to find the [Overlay] in decedents tree.
class OverlayFinder extends StatefulWidget {
  final Widget child;

  OverlayFinder({required this.child}) : super(key: _keyFinder);

  @override
  _OverlayFinderState createState() => _OverlayFinderState();
}

class _OverlayFinderState extends State<OverlayFinder> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
