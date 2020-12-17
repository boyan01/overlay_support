import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/theme.dart';

import 'overlay_keys.dart';
import 'overlay_state_finder.dart';

part 'overlay_animation.dart';

part 'overlay_entry.dart';

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
  Curve? curve,
  Duration? duration,
  Key? key,
  BuildContext? context,
}) {
  assert(key is! GlobalKey);

  assert(context != null || _debugInitialized,
      'OverlaySupport Not Initialized ! \nensure your app wrapped widget OverlaySupport');

  final OverlaySupportState? overlaySupport = findOverlayState(context: context);
  final OverlayState? overlay = overlaySupport?.overlayState;
  if (overlaySupport == null || overlay == null) {
    assert(() {
      debugPrint('overlay not available, dispose this call : $key');
      return true;
    }());
    return OverlaySupportEntry.empty();
  }

  final overlayKey = key ?? UniqueKey();

  final oldSupportEntry = overlaySupport.getEntry(key: overlayKey);
  if (oldSupportEntry != null && key is ModalKey) {
    // Do nothing for modal key if there be a OverlayEntry hold the same model key
    // and it is showing.
    return oldSupportEntry;
  }

  final dismissImmediately = key is TransientKey;
  // If we got a showing overlaySupport with [key], we should dismiss it before showing a new.
  oldSupportEntry?.dismiss(animate: !dismissImmediately);

  final stateKey = GlobalKey<_AnimatedOverlayState>();
  final OverlayEntry entry = OverlayEntry(builder: (context) {
    return KeyedOverlay(
      key: overlayKey,
      child: _AnimatedOverlay(
        key: stateKey,
        builder: builder,
        curve: curve,
        animationDuration: kNotificationSlideDuration,
        duration: duration ?? kNotificationDuration,
        overlayKey: overlayKey,
        overlaySupportState: overlaySupport,
      ),
    );
  });
  final OverlaySupportEntry supportEntry = OverlaySupportEntry(entry, overlayKey, stateKey, overlaySupport);
  overlaySupport.addEntry(supportEntry, key: overlayKey);
  overlay.insert(entry);
  return supportEntry;
}

bool _debugInitialized = false;

class OverlaySupport extends StatelessWidget {
  final Widget child;

  final ToastThemeData? toastTheme;

  const OverlaySupport({Key? key, required this.child, this.toastTheme}) : super(key: key);

  OverlaySupportState? of(BuildContext context) {
    return context.findAncestorStateOfType<OverlaySupportState>();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalOverlaySupport(
      toastTheme: toastTheme ?? ToastThemeData(),
      child: child,
    );
  }
}

class GlobalOverlaySupport extends StatefulWidget {
  final Widget child;

  final ToastThemeData? toastTheme;

  GlobalOverlaySupport({this.toastTheme, required this.child}) : super(key: keyFinder);

  @override
  StatefulElement createElement() {
    _debugInitialized = true;
    return super.createElement();
  }

  @override
  _GlobalOverlaySupportState createState() => _GlobalOverlaySupportState();
}

class _GlobalOverlaySupportState extends OverlaySupportState<GlobalOverlaySupport> {
  @override
  Widget build(BuildContext context) {
    assert(() {
      if (context.findAncestorWidgetOfExactType<GlobalOverlaySupport>() != null) {
        throw FlutterError('There is already an GlobalOverlaySupport in the Widget tree.');
      }
      return true;
    }());
    return OverlaySupportTheme(
      toastTheme: widget.toastTheme ?? OverlaySupportTheme.toast(context) ?? ToastThemeData(),
      child: widget.child,
    );
  }

  @override
  OverlayState? get overlayState {
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
}

class LocalOverlaySupport extends StatefulWidget {
  final Widget child;

  final ToastThemeData? toastTheme;

  const LocalOverlaySupport({
    Key? key,
    this.toastTheme,
    required this.child,
  }) : super(key: key);

  @override
  _LocalOverlaySupportState createState() => _LocalOverlaySupportState();
}

class _LocalOverlaySupportState extends OverlaySupportState<LocalOverlaySupport> {
  final GlobalKey<OverlayState> _overlayStateKey = GlobalKey();

  @override
  OverlayState? get overlayState => _overlayStateKey.currentState;

  @override
  Widget build(BuildContext context) {
    return OverlaySupportTheme(
      toastTheme: widget.toastTheme ?? OverlaySupportTheme.toast(context) ?? ToastThemeData(),
      child: Overlay(
        key: _overlayStateKey,
        initialEntries: [OverlayEntry(builder: (context) => widget.child)],
      ),
    );
  }
}

abstract class OverlaySupportState<T extends StatefulWidget> extends State<T> {
  final Map<Key, OverlaySupportEntry> _entries = HashMap();

  OverlayState? get overlayState;

  OverlaySupportEntry? getEntry({required Key key}) {
    return _entries[key];
  }

  void addEntry(OverlaySupportEntry entry, {required Key key}) {
    _entries[key] = entry;
  }

  void removeEntry({required Key key}) {
    _entries.remove(key);
  }
}
