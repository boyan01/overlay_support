import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/theme.dart';

part 'overlay_animation.dart';
part 'overlay_entry.dart';
part 'overlay_key.dart';

/// To build a widget with animated value.
/// [progress] : the progress of overlay animation from 0 - 1
///
/// A simple use case is [TopSlideNotification] in [showOverlayNotification].
///
typedef Widget AnimatedOverlayWidgetBuilder(BuildContext context, double progress);

/// Basic api to show overlay widget.
///
/// [duration] : the overlay display duration , overlay will auto dismiss after [duration].
/// if null , will be set to [kNotificationDuration].
/// if zero , will not auto dismiss in the future.
///
/// [builder] : see [AnimatedOverlayWidgetBuilder].
///
/// [curve] : adjust the rate of change of an animation.
///
/// [key] : to identify a OverlayEntry.
///
/// for example:
/// ```dart
/// final key = ValueKey('my overlay');
///
/// // step 1: popup a overlay
/// showOverlay(builder, key: key);
///
/// // step 2: popup a overlay use the same key
/// showOverlay(builder2, key: key);
/// ```
///
/// If the notification1 of step1 is showing, the step2 will dismiss previous notification1.
///
/// If you want notification1' exist to prevent step2, please see [ModalKey]
///
///
OverlaySupportEntry showOverlay(
  AnimatedOverlayWidgetBuilder builder, {
  Curve curve,
  Duration duration,
  Key key,
}) {
  assert(key is! GlobalKey);
  assert(_debugInitialized, 'OverlaySupport Not Initialized ! \nensure your app wrapped widget OverlaySupport');

  duration ??= kNotificationDuration;

  final OverlayState overlay = _overlayState;
  if (overlay == null) {
    assert(() {
      debugPrint('overlay not available, dispose this call : $key');
      return true;
    }());
    return OverlaySupportEntry.empty();
  }

  final overlayKey = _OverlayKey(key);

  final supportEntry = OverlaySupportEntry._entries[overlayKey];
  if (supportEntry != null && key is ModalKey) {
    // Do nothing for modal key if there be a OverlayEntry hold the same model key
    // and it is showing.
    return supportEntry;
  }

  final dismissImmediately = key is TransientKey;
  // If we got a showing overlay with [key], we should dismiss it before showing a new.
  supportEntry?.dismiss(animate: !dismissImmediately);

  final stateKey = GlobalKey<_AnimatedOverlayState>();
  OverlaySupportEntry entry = OverlaySupportEntry(OverlayEntry(builder: (context) {
    return _KeyedOverlay(
      key: overlayKey,
      child: _AnimatedOverlay(
        key: stateKey,
        builder: builder,
        curve: curve,
        animationDuration: kNotificationSlideDuration,
        duration: duration,
      ),
    );
  }), overlayKey, stateKey);

  overlay.insert(entry._entry);

  return entry;
}

final GlobalKey<_OverlayFinderState> _keyFinder = GlobalKey(debugLabel: 'overlay_support');

OverlayState get _overlayState {
  final context = _keyFinder.currentContext;
  if (context == null) return null;

  NavigatorState navigator;
  void visitor(Element element) {
    if (navigator != null) return;

    if (element.widget is Navigator) {
      navigator = (element as StatefulElement).state;
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
  return navigator.overlay;
}

bool _debugInitialized = false;

class OverlaySupport extends StatelessWidget {
  final Widget child;

  final ToastThemeData toastTheme;

  const OverlaySupport({Key key, @required this.child, this.toastTheme}) : super(key: key);

  @override
  StatelessElement createElement() {
    _debugInitialized = true;
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (context.ancestorWidgetOfExactType(OverlaySupport) != null) {
        throw FlutterError('There is already an OverlaySupport in the Widget tree.');
      }
      return true;
    }());
    return OverlaySupportTheme(
      toastTheme: toastTheme ?? ToastThemeData(),
      child: _OverlayFinder(key: _keyFinder, child: child),
    );
  }
}

/// Used to find the [Overlay] in decedents tree.
class _OverlayFinder extends StatefulWidget {
  final Widget child;

  const _OverlayFinder({Key key, this.child}) : super(key: key);

  @override
  _OverlayFinderState createState() => _OverlayFinderState();
}

class _OverlayFinderState extends State<_OverlayFinder> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
