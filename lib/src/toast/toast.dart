import 'package:flutter_web/material.dart';
import 'package:overlay_support/src/overlay.dart';

class Toast {
  Toast._private();

  ///Show the view or text notification for a short period of time.  This time
  ///could be user-definable.  This is the default.
  static const LENGTH_SHORT = const Duration(milliseconds: 2000);

  ///Show the view or text notification for a long period of time.  This time
  ///could be user-definable.
  static const LENGTH_LONG = const Duration(milliseconds: 3500);
}

///popup a message in front of screen
///
/// [duration] the duration to show a toast,
/// for most situation, you can use [Toast.LENGTH_SHORT] and [Toast.LENGTH_LONG]
///
void toast(BuildContext context, String message,
    {Duration duration = Toast.LENGTH_SHORT}) {
  if (duration <= Duration.zero) {
    //fast fail
    return;
  }

  showOverlay(context, (context, t) {
    return Opacity(
        opacity: t,
        child: _Toast(
          content: Text(message),
        ));
  },
      curve: Curves.ease,
      key: const ValueKey('overlay_toast'),
      duration: duration);
}

class _Toast extends StatelessWidget {
  final Widget content;

  const _Toast({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final toastTheme = ToastTheme.of(context);

    return SafeArea(
      child: DefaultTextStyle(
        style: TextStyle(color: toastTheme?.textColor ?? _default_label_color),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: toastTheme?.alignment ?? _default_alignment,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: toastTheme?.background ?? _default_background_color,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _default_background_color = const Color(0x8ecccccc);

const _default_label_color = Colors.black87;

const _default_alignment = Alignment(0, 0.618);

///to custom toast style
class ToastTheme extends InheritedWidget {
  final Color textColor;

  final Color background;

  final Alignment alignment;

  const ToastTheme({
    this.textColor = _default_background_color,
    this.background = _default_label_color,
    this.alignment = _default_alignment,
    Key key,
    @required Widget child,
  })  : assert(child != null),
        assert(textColor != null),
        assert(background != null),
        assert(alignment != null),
        super(key: key, child: child);

  static ToastTheme of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ToastTheme) as ToastTheme;
  }

  @override
  bool updateShouldNotify(ToastTheme old) {
    return textColor != old.textColor || background != old.background;
  }
}
