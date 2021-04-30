import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_support/overlay_support.dart';

import 'overlay_support_test.dart';

void main() {
  setUp(() {
    kNotificationSlideDuration = Duration.zero;
    kNotificationDuration = const Duration(milliseconds: 1);
  });

  group('basic function test', () {
    testWidgets('global', (tester) async {
      await basicFunction(tester, true);
    });

    testWidgets('local', (tester) async {
      await basicFunction(tester, false);
    });
  });

  group('zero duration', () {
    testWidgets('global', (tester) async {
      await tester.pumpWidget(FakeOverlay(
        child: Builder(builder: (context) {
          return TextButton(
              onPressed: () {
                toast('message', duration: Duration.zero);
              },
              child: Text('toast'));
        }),
      ));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('message'), findsNothing);
    });

    testWidgets('local', (tester) async {
      await tester.pumpWidget(FakeOverlay(
        child: Builder(builder: (context) {
          return TextButton(
              onPressed: () {
                toast('message', duration: Duration.zero, context: context);
              },
              child: Text('toast'));
        }),
      ));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('message'), findsNothing);
    });
  });
}

Future<void> basicFunction(WidgetTester tester, bool global) async {
  await tester.pumpWidget(
    FakeOverlay(
      child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              if (global) {
                toast('message', duration: const Duration(milliseconds: 1));
              } else {
                toast('message', duration: const Duration(milliseconds: 1), context: context);
              }
            },
            child: Text('toast'));
      }),
    ),
  );
  await tester.pump();
  await tester.tap(find.byType(TextButton));
  await tester.pump();

  expect(find.text('message'), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 50));
  //already hidden
  expect(find.text('message'), findsNothing);
}
