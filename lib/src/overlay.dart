import 'dart:async';

import 'package:async/async.dart';
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

    //update the overlay widget
    element.owner.lockState(() {
      element.update(_AnimatedOverlay(
        key: supportEntry._stateKey,
        builder: builder,
        curve: curve,
        duration: duration,
        animationDuration: kNotificationSlideDuration,
      ));
    });
    return supportEntry;
  }

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

  TickerFuture _forwarding;

  CancelableOperation _showTask;

  CancelableOperation _dismissTask;

  void show() {
    _dismissTask?.cancel();
    _showTask?.cancel();

    _forwarding = _controller.forward(from: _controller.value);
    _showTask = CancelableOperation.fromFuture(
        Future.wait([_forwarding, Future.delayed(widget.duration)]))
      ..value.whenComplete(() {
        _showTask = null;
        if (widget.duration != Duration.zero) {
          hide();
        }
      });
  }

  void hide({bool immediately = false}) async {

    _dismissTask?.cancel();
    _showTask?.cancel();

    if (!immediately && _showTask != null) {
      await _forwarding;
    }
    final reverse = _controller.reverse(from: _controller.value);
    _dismissTask = CancelableOperation.fromFuture(reverse)
      ..value.whenComplete(() {
        OverlaySupportEntry.of(context).dismiss(animate: false);
      });
  }

  @override
  void didUpdateWidget(_AnimatedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      bool needShow = widget.duration != oldWidget.duration ||
          widget.builder != oldWidget.builder ||
          widget.key != oldWidget.key ||
          widget.curve != oldWidget.curve ||
          widget.animationDuration != oldWidget.animationDuration;

      if (widget.duration != oldWidget.duration) {
        _controller?.dispose();
        _controller = AnimationController(
            vsync: this,
            duration: widget.animationDuration,
            debugLabel: 'AnimatedOverlayShowHideAnimation');
      }
      if (needShow) {
        _showTask?.cancel();
        _dismissTask?.cancel();
        _showTask = null;
        _dismissTask = null;
        setState(() {
          show();
        });
      }
    });
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
    _controller?.dispose();
    _dismissTask?.cancel();
    _showTask?.cancel();
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
