import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

part 'overlay_entry.dart';

part 'overlay_key.dart';

/// to build a widget with animated value
/// [progress] : the progress of overlay animation from 0 - 1
///
/// a simple use case is [TopSlideNotification] in [showOverlayNotification]
///
typedef Widget AnimatedOverlayWidgetBuilder(
    BuildContext context, double progress);

///basic api to show overlay widget
///
///[duration] the overlay display duration , overlay will auto dismiss after [duration]
///if null , will be set to [kNotificationDuration]
///if zero , will not auto dismiss in the future
///
///[builder], see [AnimatedOverlayWidgetBuilder]
///
///[curve], adjust the rate of change of an animation
///
///[key] to identify a OverlayEntry.
///
/// for example:
/// ```dart
/// final key = ValueKey('my overlay');
///
/// //step 1: popup a overlay
/// showOverlay(context, builder, key: key);
///
/// //step 2: popup a overlay use the same key
/// showOverlay(context, builder2, key: key);
/// ```
///
/// if the notification1 of step1 is showing, the step2 will dismiss previous notification1.
///
/// if you want notification1' exist to prevent step2, please see [ModalKey]
///
///
OverlaySupportEntry showOverlay(
  BuildContext context,
  AnimatedOverlayWidgetBuilder builder, {
  Curve curve,
  Duration duration,
  Key key,
}) {
  assert(key is! GlobalKey);

  duration ??= kNotificationDuration;

  final OverlayState overlay =
      context.rootAncestorStateOfType(const TypeMatcher<OverlayState>());
  assert(overlay != null,
      "can not find OverlayState, ensure your app wrapped a widget named Overlay");

  final overlayKey = _OverlayKey(key);

  final supportEntry = OverlaySupportEntry._entries[overlayKey];
  if (supportEntry != null && key is ModalKey) {
    //do nothing for reject key
    return supportEntry;
  }
  //dismiss existed entry
  supportEntry?.dismiss(animate: true);

  final stateKey = GlobalKey<_AnimatedOverlayState>();
  OverlaySupportEntry entry =
      OverlaySupportEntry(overlayKey, OverlayEntry(builder: (context) {
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
  }), stateKey);

  overlay.insert(entry._entry);

  return entry;
}

class _AnimatedOverlay extends StatefulWidget {
  ///overlay display total duration
  ///zero means overlay display forever
  final Duration duration;

  ///overlay show/hide animation duration
  final Duration animationDuration;

  final AnimatedOverlayWidgetBuilder builder;

  final Curve curve;

  _AnimatedOverlay(
      {@required Key key,
      @required this.animationDuration,
      Curve curve,
      @required this.builder,
      @required this.duration})
      : curve = curve ?? Curves.easeInOut,
        assert(animationDuration != null && animationDuration >= Duration.zero),
        assert(duration != null && duration >= Duration.zero),
        assert(builder != null),
        super(key: key);

  @override
  _AnimatedOverlayState createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<_AnimatedOverlay>
    with TickerProviderStateMixin {
  AnimationController _controller;

  CancelableOperation _autoHideOperation;

  void show() {
    _autoHideOperation?.cancel();
    _controller.forward(from: _controller.value);
  }

  Future hide({bool immediately = false}) async {
    if (!immediately &&
        !_controller.isDismissed &&
        _controller.status == AnimationStatus.forward) {
      await _controller.forward(from: _controller.value);
    }
    _autoHideOperation?.cancel();
    await _controller.reverse(from: _controller.value);
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        debugLabel: 'AnimatedOverlayShowHideAnimation');
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        OverlaySupportEntry._entriesGlobal[widget.key].dismiss(animate: false);
      } else if (status == AnimationStatus.completed) {
        if (widget.duration > Duration.zero) {
          _autoHideOperation =
              CancelableOperation.fromFuture(Future.delayed(widget.duration))
                ..value.whenComplete(() {
                  hide();
                });
        }
      }
    });
    show();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _autoHideOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return widget.builder(
              context, widget.curve.transform(_controller.value));
        });
  }
}
