import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  testWidgets("theme", (tester) async {
    final Color presetTextColor = Colors.white38;
    final Color presetBackground = Colors.amber;
    final Alignment presetToastAlignment = Alignment(0.2, 0.2);

    OverlaySupportTheme? theme;
    await tester.pumpWidget(GlobalOverlaySupport(
      toastTheme: ToastThemeData(
        textColor: presetTextColor,
        background: presetBackground,
        alignment: presetToastAlignment,
      ),
      child: MaterialApp(home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return FlatButton(
              onPressed: () {
                theme = OverlaySupportTheme.of(context);
              },
              child: Text("Button"),
            );
          }),
        ),
      )),
    ));
    await tester.pump();
    await tester.tap(find.text("Button"));
    await tester.pump();
    expect(theme, isNotNull);
    expect(theme?.toastTheme.textColor, equals(presetTextColor));
    expect(theme?.toastTheme.background, equals(presetBackground));
    expect(theme?.toastTheme.alignment, equals(presetToastAlignment));
  });
}
