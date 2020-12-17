import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

OverlaySupportState? findOverlayState({BuildContext? context}) {
  if (context == null) {
    return _globalOverlayState;
  }
  final OverlaySupportState? overlaySupportState = context.findAncestorStateOfType<OverlaySupportState>();
  return overlaySupportState;
}

final GlobalKey<OverlaySupportState> keyFinder = GlobalKey(debugLabel: 'overlay_support');

OverlaySupportState? get _globalOverlayState {
  final OverlaySupportState? state = keyFinder.currentState;
  assert(() {
    if (state == null) {
      throw FlutterError('''we can not find OverlaySupportState in your app.
         
         do you declare GlobalOverlaySupport you app widget tree like this?
         
         GlobalOverlaySupport(
           child: MaterialApp(
             title: 'Overlay Support Example',
             home: HomePage(),
           ),
         )
      
      ''');
    }
    return true;
  }());
  return state;
}
