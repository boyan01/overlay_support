part of 'overlay.dart';

class _AnimatedOverlay extends StatefulWidget {
  ///overlay display total duration
  ///zero means overlay display forever
  final Duration duration;

  ///overlay show/hide animation duration
  final Duration animationDuration;

  final AnimatedOverlayWidgetBuilder builder;

  final AnimatedOverlayRemovedWidgetBuilder removedBuilder;

  _AnimatedOverlay(
      {@required Key key,
      @required this.animationDuration,
      @required this.builder,
      @required this.duration,
      AnimatedOverlayRemovedWidgetBuilder removedBuilder})
      : assert(animationDuration != null && animationDuration >= Duration.zero),
        assert(duration != null && duration >= Duration.zero),
        assert(builder != null),
        this.removedBuilder = removedBuilder ?? builder,
        super(key: key);

  @override
  _AnimatedOverlayState createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<_AnimatedOverlay> with TickerProviderStateMixin {
  AnimationController _controller;

  CancelableOperation _autoHideOperation;

  void show() {
    _autoHideOperation?.cancel();
    _controller.forward(from: _controller.value);
  }

  ///
  /// [immediately] True to dismiss notification immediately.
  ///
  Future hide({bool immediately = false}) async {
    if (!immediately && !_controller.isDismissed && _controller.status == AnimationStatus.forward) {
      await _controller.forward(from: _controller.value);
    }
    _autoHideOperation?.cancel();
    await _controller.reverse(from: _controller.value);
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: widget.animationDuration, debugLabel: 'AnimatedOverlayShowHideAnimation');
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        OverlaySupportEntry._entriesGlobal[widget.key].dismiss(animate: false);
      } else if (status == AnimationStatus.completed) {
        if (widget.duration > Duration.zero) {
          _autoHideOperation = CancelableOperation.fromFuture(Future.delayed(widget.duration))
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
    switch (_controller.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return Builder(builder: (context) => widget.builder(context, _controller));
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        return Builder(builder: (context) => widget.removedBuilder(context, _controller));
    }
    // Unreachable logic
    return const SizedBox();
  }
}
