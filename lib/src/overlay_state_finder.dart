import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

final GlobalKey<OverlaySupportState> _keyFinder =
    GlobalKey(debugLabel: 'overlay_support');

OverlaySupportState? findOverlayState({BuildContext? context}) {
  if (context == null) {
    assert(
      _debugInitialized,
      'Global OverlaySupport Not Initialized ! \n'
      'ensure your app wrapped widget OverlaySupport.global',
    );
    final state = _keyFinder.currentState;
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
  final overlaySupportState =
      context.findAncestorStateOfType<OverlaySupportState>();
  return overlaySupportState;
}

bool _debugInitialized = false;

class OverlaySupport extends StatelessWidget {
  final Widget child;

  final ToastThemeData? toastTheme;

  final bool global;

  const OverlaySupport({
    Key? key,
    required this.child,
    this.toastTheme,
    this.global = true,
  }) : super(key: key);

  const OverlaySupport.global({
    Key? key,
    required this.child,
    this.toastTheme,
  }) : global = true;

  const OverlaySupport.local({
    Key? key,
    required this.child,
    this.toastTheme,
  }) : global = false;

  OverlaySupportState? of(BuildContext context) {
    return context.findAncestorStateOfType<OverlaySupportState>();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupportTheme(
      toastTheme:
          toastTheme ?? OverlaySupportTheme.toast(context) ?? ToastThemeData(),
      child: global
          ? _GlobalOverlaySupport(child: child)
          : _LocalOverlaySupport(child: child),
    );
  }
}

class _GlobalOverlaySupport extends StatefulWidget {
  final Widget child;

  _GlobalOverlaySupport({required this.child}) : super(key: _keyFinder);

  @override
  StatefulElement createElement() {
    _debugInitialized = true;
    return super.createElement();
  }

  @override
  _GlobalOverlaySupportState createState() => _GlobalOverlaySupportState();
}

class _GlobalOverlaySupportState
    extends OverlaySupportState<_GlobalOverlaySupport> {
  @override
  Widget build(BuildContext context) {
    assert(() {
      if (context.findAncestorWidgetOfExactType<_GlobalOverlaySupport>() !=
          null) {
        throw FlutterError(
            'There is already an GlobalOverlaySupport in the Widget tree.');
      }
      return true;
    }());
    return widget.child;
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

    assert(navigator != null,
        '''It looks like you are not using Navigator in your app.
         
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

class _LocalOverlaySupport extends StatefulWidget {
  final Widget child;

  const _LocalOverlaySupport({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _LocalOverlaySupportState createState() => _LocalOverlaySupportState();
}

class _LocalOverlaySupportState
    extends OverlaySupportState<_LocalOverlaySupport> {
  final GlobalKey<OverlayState> _overlayStateKey = GlobalKey();

  @override
  OverlayState? get overlayState => _overlayStateKey.currentState;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayStateKey,
      initialEntries: [OverlayEntry(builder: (context) => widget.child)],
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
