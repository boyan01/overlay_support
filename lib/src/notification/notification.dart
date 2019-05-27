import 'package:flutter_web/material.dart';

/// a notification show in front of screen and shown at the top
class TopSlideNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final double progress;

  const TopSlideNotification({Key key, @required this.builder, this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation:
          Offset.lerp(const Offset(0, -1), const Offset(0, 0), progress),
      child: builder(context),
    );
  }
}
