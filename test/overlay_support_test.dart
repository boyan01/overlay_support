import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  setUp(() {
    kNotificationSlideDuration = Duration.zero;
    kNotificationDuration = const Duration(milliseconds: 20);
  });

  group('toast', () {
    testWidgets('toast functional test', (tester) async {
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              toast(context, 'message');
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
      NotificationEntry entry;
      await tester.pumpWidget(_FakeOverlay(child: Builder(builder: (context) {
        return FlatButton(
            onPressed: () {
              entry = showSimpleNotification(context, Text('message'));
            },
            child: Text('notification'));
      })));
      await tester.pump();
      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      assert(!entry.dismissEnd.isCompleted);
      assert(!entry.dismissStart.isCompleted);
      expect(find.text('message'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));

      //already hidden
      expect(find.text('message'), findsNothing);
      assert(entry.dismissEnd.isCompleted);
    });

    testWidgets('notification hide manually', (tester) async {
      NotificationEntry entry;
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

      //but in second frame, this notification has been dismissed
      await tester.pump();
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
