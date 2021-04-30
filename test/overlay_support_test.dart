import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/overlay.dart';
import 'package:pedantic/pedantic.dart';

void main() {
  setUp(() {
    kNotificationSlideDuration = Duration.zero;
    kNotificationDuration = const Duration(milliseconds: 1);
  });

  group('simple notification', () {
    testWidgets('global', (tester) async {
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              showSimpleNotification(Text('message'));
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('message'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));

      //already hidden
      expect(find.text('message'), findsNothing);
    });

    testWidgets('local', (tester) async {
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              showSimpleNotification(Text('message'), context: context);
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('message'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));

      //already hidden
      expect(find.text('message'), findsNothing);
    });
  });

  group('simple notification hide by returned entry', () {
    testWidgets('global', (tester) async {
      OverlaySupportEntry? entry;
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              entry = showSimpleNotification(Text('message'), autoDismiss: false);
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      assert(entry != null, 'entry has been inited by tap event');
      expect(find.text('message'), findsOneWidget);

      entry!.dismiss(animate: false);
      await tester.pump();

      //already hidden
      expect(find.text('message'), findsNothing);

      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('local', (tester) async {
      OverlaySupportEntry? entry;
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              entry = showSimpleNotification(Text('message'), autoDismiss: false, context: context);
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      assert(entry != null, 'entry has been inited by tap event');
      expect(find.text('message'), findsOneWidget);

      entry!.dismiss(animate: false);
      await tester.pump();

      //already hidden
      expect(find.text('message'), findsNothing);

      await tester.pump(const Duration(milliseconds: 50));
    });
  });

  group('simple notification hide immediately', () {
    testWidgets('global', (tester) async {
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              final entry = showSimpleNotification(Text('message'), autoDismiss: false);
              //dismiss immediately
              entry.dismiss();
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));

      await tester.pump();
      //we got a notification in first frame
      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('message'), findsNothing);
    });

    testWidgets('local', (tester) async {
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              final entry = showSimpleNotification(Text('message'), autoDismiss: false, context: context);
              //dismiss immediately
              entry.dismiss();
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(TextButton));

      await tester.pump();
      //we got a notification in first frame
      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('message'), findsNothing);
    });
  });

  group('simple notification behavior on back pressed', () {
    Widget _buildTestTree({required void Function(BuildContext context, Widget child) show}) {
      return FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Overlay(initialEntries: [
                  OverlayEntry(builder: (context) {
                    return Builder(
                      builder: (context) {
                        return ElevatedButton(
                            onPressed: () {
                              show(context, Text('message'));
                              Navigator.pop(context);
                            },
                            child: Text('popup'));
                      },
                    );
                  })
                ]);
              }));
            },
            child: Text('new'));
      }));
    }

    testWidgets('global', (tester) async {
      await tester.pumpWidget(_buildTestTree(show: (context, child) {
        showSimpleNotification(child);
      }));
      await tester.pump();
      await tester.tap(find.byType(TextButton));

      await tester.pump();
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));

      await tester.pump();
      await tester.pump();
      expect(find.text('popup'), findsNothing);
      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      //already hidden
      expect(find.text('message'), findsNothing);
    });

    testWidgets('local', (tester) async {
      await tester.pumpWidget(_buildTestTree(show: (context, child) {
        showSimpleNotification(child, context: context);
      }));
      await tester.pump();
      await tester.tap(find.byType(TextButton));

      await tester.pump();
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));

      await tester.pump();
      await tester.pump();
      expect(find.text('popup'), findsNothing);
      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      //already hidden
      expect(find.text('message'), findsNothing);
    });
  });

  group('key', () {
    testWidgets('overlay with the normal key', (tester) async {
      kNotificationSlideDuration = Duration(milliseconds: 200);
      kNotificationDuration = const Duration(milliseconds: 1000);
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message'), autoDismiss: false, key: ValueKey('hello'));
                },
                child: Text('notification')),
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message2'), autoDismiss: false, key: ValueKey('hello'));
                },
                child: Text('notification2')),
          ],
        );
      })));
      await tester.tap(find.text('notification'));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('message'), findsOneWidget);

      await tester.tap(find.text('notification2'));
      await tester.pump();
      expect(find.text('message'), findsOneWidget);
      expect(find.text('message2'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1250));
    });

    testWidgets('overlay with the modal key', (tester) async {
      kNotificationSlideDuration = Duration(milliseconds: 200);
      kNotificationDuration = const Duration(milliseconds: 1000);
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message'), autoDismiss: false, key: ModalKey('hello'));
                },
                child: Text('notification')),
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message2'), autoDismiss: false, key: ModalKey('hello'));
                },
                child: Text('notification2')),
          ],
        );
      })));
      await tester.tap(find.text('notification'));
      await tester.pump();
      expect(find.text('message'), findsOneWidget);

      await tester.tap(find.text('notification2'));
      await tester.pump();
      expect(find.text('message'), findsOneWidget);

      //find nothing because message2 was been rejected
      expect(find.text('message2'), findsNothing);
    });

    testWidgets('overlay with the transient key', (tester) async {
      kNotificationSlideDuration = Duration(milliseconds: 200);
      kNotificationDuration = const Duration(milliseconds: 1000);
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message'), autoDismiss: false, key: TransientKey('transient'));
                },
                child: Text('notification')),
            TextButton(
                onPressed: () {
                  showSimpleNotification(Text('message2'), autoDismiss: false, key: TransientKey('transient'));
                },
                child: Text('notification2')),
          ],
        );
      })));
      await tester.tap(find.text('notification'));
      await tester.pump();
      expect(find.text('message'), findsOneWidget);

      await tester.tap(find.text('notification2'));
      await tester.pump();
      // "message2" popup, "message" dismissed.
      expect(find.text('message2'), findsOneWidget);
      expect(find.text('message'), findsNothing);
    });
  });

  group('overlay support entry', () {
    testWidgets('find OverlaySupportEntry by context', (tester) async {
      OverlaySupportEntry? entry;
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              showSimpleNotification(Text('message'), trailing: Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    entry = OverlaySupportEntry.of(context);
                  },
                  child: Text('entry'),
                );
              }), autoDismiss: false);
            },
            child: Text('notification'));
      })));

      await tester.tap(find.text('notification'));
      await tester.pump();
      expect(find.text('entry'), findsOneWidget);

      await tester.tap(find.text('entry'));
      await tester.pump();

      assert(entry != null);
    });

    testWidgets('overlay support entry dismissed', (tester) async {
      OverlaySupportEntry? entry;
      await tester.pumpWidget(FakeOverlay(child: Builder(builder: (context) {
        return TextButton(
            onPressed: () {
              entry = showSimpleNotification(Text('message'), autoDismiss: true);
            },
            child: Text('notification'));
      })));

      await tester.tap(find.text('notification'));
      await tester.pump();

      assert(entry != null);
      var dismissed = false;
      unawaited(entry!.dismissed.whenComplete(() {
        dismissed = true;
      }));
      await tester.pump(Duration(milliseconds: 100));
      assert(dismissed);
    });
  });
}

class FakeOverlay extends StatelessWidget {
  final Widget child;

  const FakeOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        home: OverlaySupport.local(
          child: Scaffold(
            body: child,
          ),
        ),
      ),
    );
  }
}
