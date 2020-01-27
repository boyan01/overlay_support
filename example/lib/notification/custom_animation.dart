import 'package:flutter/material.dart';
import 'package:overlay_support_example/notification/ios_toast.dart';

import 'ios_toast.dart';

/// Example to show how to popup overlay with custom animation.
class CustomAnimationToast extends StatelessWidget {
  final Animation<double> animation;

  static final Tween<Offset> tweenOffset = Tween<Offset>(begin: Offset(0, 40), end: Offset(0, 0));

  static final Tween<double> tweenOpacity = Tween<double>(begin: 0, end: 1);

  const CustomAnimationToast({Key key, @required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = CurveTween(curve: Curves.decelerate).animate(this.animation);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: tweenOffset.transform(animation.value),
          child: FadeTransition(
            opacity: animation,
            child: IosStyleToast(),
          ),
        );
      },
    );
  }
}
