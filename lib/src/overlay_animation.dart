part of 'overlay.dart';

class _AnimatedOverlay extends StatefulWidget {
  /// The total duration of overlay display.
  /// [Duration.zero] means overlay display forever.
  final Duration duration;

  /// The duration overlay show/hide's animation.
  final Duration animationDuration;

  final AnimatedOverlayWidgetBuilder builder;

  final Curve curve;

  final _OverlayKey overlayKey;

  _AnimatedOverlay({
    required Key key,
    required this.animationDuration,
    Curve? curve,
    required this.builder,
    required this.duration,
    required this.overlayKey,
  })   : curve = curve ?? Curves.easeInOut,
        assert(animationDuration >= Duration.zero),
        assert(duration >= Duration.zero),
        super(key: key);

  @override
  _AnimatedOverlayState createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<_AnimatedOverlay> with TickerProviderStateMixin {
  late AnimationController _controller;

  CancelableOperation? _autoHideOperation;

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
        OverlaySupportEntry._overlayEntry(key: widget.overlayKey)?.dismiss(animate: false);
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
    _controller.dispose();
    _autoHideOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return widget.builder(context, widget.curve.transform(_controller.value));
        });
  }
}
