import 'package:flutter_web/material.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/overlay.dart';

void main() {
  setUp(() {
    kNotificationSlideDuration = Duration.zero;
    kNotificationDuration = const Duration(milliseconds: 1);
  });

  group('toast', () {
    testWidgets('toast functional test', (tester) async {
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              toast(context, 'message',
                  duration: const Duration(milliseconds: 1));
            },
            child: Text('toast'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      //already hidden
      expect(find.text('message'), findsNothing);
    });

    testWidgets('toast zero duration', (tester) async {
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              toast(context, 'message', duration: Duration.zero);
            },
            child: Text('toast'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      expect(find.text('message'), findsNothing);
    });
  });

  group('notification', () {
    testWidgets('notification functional test', (tester) async {
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              showSimpleNotification(context, Text('message'));
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      expect(find.text('message'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));

      //already hidden
      expect(find.text('message'), findsNothing);
    });

    testWidgets('notification hide manually', (tester) async {
      OverlaySupportEntry entry;
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              entry = showSimpleNotification(context, Text('message'),
                  autoDismiss: false);
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      assert(entry != null, 'entry has been inited by tap event');
      expect(find.text('message'), findsOneWidget);

      entry.dismiss(animate: false);
      await tester.pump();

      //already hidden
      expect(find.text('message'), findsNothing);

      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('notification hide by manual immediately', (tester) async {
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              final entry = showSimpleNotification(context, Text('message'),
                  autoDismiss: false);
              //dismiss immediately
              entry.dismiss();
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));

      await tester.pump();
      //we got a notification in first frame
      expect(find.text('message'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('message'), findsNothing);
    });
  });

  testWidgets('notification dismiss in duplicate Overlay', (tester) async {
    await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
      return FlatButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Overlay(initialEntries: [
                OverlayEntry(builder: (context) {
                  return Builder(
                    builder: (context) {
                      return RaisedButton(
                          onPressed: () {
                            showSimpleNotification(context, Text('message'));
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
    })));
    await tester.pump();
    await tester.tap(find.byType(FlatButton));

    await tester.pump();
    await tester.pump();
    await tester.tap(find.byType(RaisedButton));

    await tester.pump();
    await tester.pump();
    expect(find.text('popup'), findsNothing);
    expect(find.text('message'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    //already hidden
    expect(find.text('message'), findsNothing);
  });

  group('key', () {
    testWidgets('overlay with the normal key', (tester) async {
      kNotificationSlideDuration = Duration(milliseconds: 200);
      kNotificationDuration = const Duration(milliseconds: 1000);
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  showSimpleNotification(context, Text('message'),
                      autoDismiss: false, key: ValueKey('hello'));
                },
                child: Text('notification')),
            FlatButton(
                onPressed: () {
                  showSimpleNotification(context, Text('message2'),
                      autoDismiss: false, key: ValueKey('hello'));
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
      expect(find.text('message2'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1250));
    });

    testWidgets('overlay with the modal key', (tester) async {
      kNotificationSlideDuration = Duration(milliseconds: 200);
      kNotificationDuration = const Duration(milliseconds: 1000);
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  showSimpleNotification(context, Text('message'),
                      autoDismiss: false, key: ModalKey('hello'));
                },
                child: Text('notification')),
            FlatButton(
                onPressed: () {
                  showSimpleNotification(context, Text('message2'),
                      autoDismiss: false, key: ModalKey('hello'));
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

      await tester.pump(const Duration(milliseconds: 1250));
    });
  });

  group('overlay support entry', () {
    testWidgets('find OverlaySupportEntry by context', (tester) async {
      OverlaySupportEntry entry;
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              showSimpleNotification(context, Text('message'),
                  trailing: Builder(builder: (context) {
                return FlatButton(
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

    testWidgets('overlay support entry dimissed', (tester) async {
      OverlaySupportEntry entry;
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              entry = showSimpleNotification(context, Text('message'),
                  autoDismiss: true);
            },
            child: Text('notification'));
      })));

      await tester.tap(find.text('notification'));
      await tester.pump();

      assert(entry != null);
      bool dismissed = false;
      entry.dismissed.whenComplete(() {
        dismissed = true;
      });
      await tester.pump(Duration(milliseconds: 100));
      assert(dismissed);
    });
  });
}

class _FakeOverlay extends StatelessWidget {
  final Widget child;

  const _FakeOverlay({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
}
