import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

part 'overlay_entry.dart';

part 'overlay_key.dart';

///progress : from 0 - 1
typedef Widget AnimatedOverlayWidgetBuilder(
    BuildContext context, double progress);

///basic api to show overlay widget
///
///[duration] the overlay display duration , overlay will auto dismiss after [duration]
///if null , will be set to [kNotificationDuration]
///if zero , will not auto dismiss in the future
///
///
OverlaySupportEntry showOverlay(
  BuildContext context,
  AnimatedOverlayWidgetBuilder builder, {
  Curve curve,
  Duration duration,
  Key key,
}) {
  duration ??= kNotificationDuration;
  final autoDismiss = duration != Duration.zero;

  final OverlayState overlay =
      context.rootAncestorStateOfType(const TypeMatcher<OverlayState>());
  assert(overlay != null,
      "can not find OverlayState, ensure your app wrapped a widget named Overlay");

  final overlayKey = _OverlayKey(key);

  final supportEntry = OverlaySupportEntry._entries[overlayKey];
  if (supportEntry != null) {
    //already got a entry is showing, so we just update this notification
    final StatefulElement element = supportEntry._stateKey.currentContext;
    assert(element != null,
        'we got a supportEntry ,but element is null. you call reported to : \nhttps://github.com/boyan01/overlay_support/issues');

    element.owner.lockState(() {
      //update the overlay widget
      element.update(_AnimatedOverlay(
          key: supportEntry._stateKey, builder: builder, curve: curve));
    });
    return supportEntry;
  }

  OverlaySupportEntry entry =
      OverlaySupportEntry(overlayKey, OverlayEntry(builder: (context) {
    return _KeyedOverlay(
      key: overlayKey,
      child: _AnimatedOverlay(
        key: overlayKey._globalKey,
        builder: builder,
        curve: curve,
      ),
    );
  }));

  overlay.insert(entry._entry);

  if (autoDismiss) {
    Future.delayed(duration + kNotificationSlideDuration).whenComplete(() {
      entry.dismiss();
    });
  }
  return entry;
}

class _AnimatedOverlay extends StatefulWidget {
  final Duration animationDuration;

  final AnimatedOverlayWidgetBuilder builder;

  final Curve curve;

  _AnimatedOverlay(
      {@required Key key,
      Duration animationDuration,
      Curve curve,
      @required this.builder})
      : animationDuration = animationDuration ?? kNotificationSlideDuration,
        curve = curve ?? Curves.easeInOut,
        assert(animationDuration == null || animationDuration >= Duration.zero),
        super(key: key);

  @override
  _AnimatedOverlayState createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<_AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  TickerFuture _forwarding;

  void show() {
    _forwarding = _controller.forward(from: _controller.value);
  }

  Future hide({bool waitShow = true}) async {
    if (waitShow) {
      if (_forwarding == null) {
        show();
      }
      await _forwarding;
    }

    final completer = Completer();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        completer.complete();
      }
    });
    _controller.reverse(from: _controller.value);
    return await completer.future;
  }

  @override
  void didUpdateWidget(_AnimatedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('update widget : $widget');
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        debugLabel: 'AnimatedOverlayShowHideAnimation');
    super.initState();
    show();
  }

  @override
  void dispose() {
    _controller.dispose();
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
