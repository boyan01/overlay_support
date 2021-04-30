import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  testWidgets('theme', (tester) async {
    final presetTextColor = Colors.white38;
    final Color presetBackground = Colors.amber;
    final presetToastAlignment = Alignment(0.2, 0.2);

    OverlaySupportTheme? theme;
    await tester.pumpWidget(OverlaySupport.global(
      toastTheme: ToastThemeData(
        textColor: presetTextColor,
        background: presetBackground,
        alignment: presetToastAlignment,
      ),
      child: MaterialApp(home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return TextButton(
              onPressed: () {
                theme = OverlaySupportTheme.of(context);
              },
              child: Text('Button'),
            );
          }),
        ),
      )),
    ));
    await tester.pump();
    await tester.tap(find.text('Button'));
    await tester.pump();
    expect(theme, isNotNull);
    expect(theme?.toastTheme.textColor, equals(presetTextColor));
    expect(theme?.toastTheme.background, equals(presetBackground));
    expect(theme?.toastTheme.alignment, equals(presetToastAlignment));
  });

  testWidgets('theme change', (tester) async {
    final theme1 = ToastThemeData(
      textColor: Colors.amber,
      background: Colors.white,
      alignment: Alignment(0, 1),
    );
    final theme2 = ToastThemeData(
      textColor: Colors.blue,
      background: Colors.black,
      alignment: Alignment(1, 0),
    );
    ToastThemeData? currentToastTheme;
    Widget createWidget(ToastThemeData toastThemeData) {
      return OverlaySupport.global(
        toastTheme: toastThemeData,
        child: MaterialApp(home: Scaffold(
          body: Center(
            child: Builder(builder: (context) {
              currentToastTheme = OverlaySupportTheme.toast(context);
              return Text('Test');
            }),
          ),
        )),
      );
    }

    await tester.pumpWidget(createWidget(theme1));
    expect(currentToastTheme, equals(theme1));
    await tester.pumpWidget(createWidget(theme2));
    expect(currentToastTheme, equals(theme2));
    await tester.pumpWidget(createWidget(theme2));
    expect(currentToastTheme, equals(theme2));
  });
}
