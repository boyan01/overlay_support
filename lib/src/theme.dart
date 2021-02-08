import 'package:flutter/material.dart';

///theme data for toast
class ToastThemeData {
  final Color textColor;

  final Color background;

  final Alignment alignment;

  const ToastThemeData.raw({
    @required this.textColor,
    @required this.background,
    @required this.alignment,
  });

  factory ToastThemeData({
    Color textColor,
    Color background,
    Alignment alignment,
  }) {
    return ToastThemeData.raw(
        textColor: textColor ?? Colors.black87,
        background: background ?? const Color(0xfceeeeee),
        alignment: alignment ?? Alignment(0, 0.618));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastThemeData &&
          runtimeType == other.runtimeType &&
          textColor == other.textColor &&
          background == other.background &&
          alignment == other.alignment;

  @override
  int get hashCode => textColor.hashCode ^ background.hashCode ^ alignment.hashCode;
}

class OverlaySupportTheme extends InheritedWidget {
  final ToastThemeData toastTheme;

  const OverlaySupportTheme({
    Key key,
    @required Widget child,
    @required this.toastTheme,
  })  : assert(child != null),
        assert(toastTheme != null),
        super(key: key, child: child);

  static OverlaySupportTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OverlaySupportTheme>();
  }

  static ToastThemeData toast(BuildContext context) {
    return of(context).toastTheme;
  }

  @override
  bool updateShouldNotify(OverlaySupportTheme old) {
    return toastTheme != old.toastTheme;
  }
}
