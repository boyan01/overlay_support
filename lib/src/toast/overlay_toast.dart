import 'package:flutter/material.dart';
import 'package:overlay_support/src/overlay.dart';

void toast(BuildContext context, String message) {
  showOverlay(context, (context, t) {
    return Opacity(
        opacity: t,
        child: _Toast(
          content: Text(message),
        ));
  }, curve: Curves.easeIn);
}

class _Toast extends StatelessWidget {
  final Widget content;

  const _Toast({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment(0, 0.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
