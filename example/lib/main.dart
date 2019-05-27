import 'dart:async';
import 'dart:math';

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'notification/custom_notification.dart';
import 'notification/ios_toast.dart';

void main() {
  kNotificationSlideDuration = const Duration(milliseconds: 500);
  kNotificationDuration = const Duration(milliseconds: 1500);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlay Support Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("overlay support example")),
      body: ListView(
        children: <Widget>[
          _Section(title: 'Notification', children: <Widget>[
            RaisedButton(
              onPressed: () {
                showSimpleNotification(
                    context, Text("this is a message from simple notification"),
                    background: Colors.green);
              },
              child: Text("Auto Dimiss Notification"),
            ),
            RaisedButton(
              onPressed: () {
                showSimpleNotification(
                  context,
                  Text("you got a simple message"),
                  trailing: Builder(builder: (context) {
                    return FlatButton(
                        textColor: Colors.yellow,
                        onPressed: () {
                          OverlaySupportEntry.of(context).dismiss();
                        },
                        child: Text('Dismiss'));
                  }),
                  background: Colors.green,
                  autoDismiss: false,
                );
              },
              child: Text("Fixed Notification"),
            )
          ]),
          _Section(title: 'Custom notification', children: <Widget>[
            RaisedButton(
              onPressed: () {
                showOverlayNotification(context, (context) {
                  return MessageNotification(
                    message: messages[3],
                    onReplay: () {
                      OverlaySupportEntry.of(context).dismiss();
                      toast(context, 'you checked this message');
                    },
                  );
                }, duration: Duration(milliseconds: 4000));
              },
              child: Text('custom message notification'),
            ),
            RaisedButton(
              onPressed: () async {
                final random = Random();
                for (var i = 0; i < messages.length; i++) {
                  await Future.delayed(
                      Duration(milliseconds: 200 + random.nextInt(1000)));
                  showOverlayNotification(context, (context) {
                    return MessageNotification(
                      message: messages[i],
                      onReplay: () {
                        OverlaySupportEntry.of(context).dismiss();
                        toast(context, 'you checked this message');
                      },
                    );
                  },
                      duration: Duration(milliseconds: 4000),
                      key: const ValueKey('message'));
                }
              },
              child: Text('message sequence'),
            ),
          ]),
          _Section(title: 'toast', children: [
            RaisedButton(
              onPressed: () {
                toast(context, 'this is a message from toast');
              },
              child: Text('toast'),
            )
          ]),
          _Section(title: 'custom', children: [
            RaisedButton(
              onPressed: () {
                showOverlay(context, (_, t) {
                  return Theme(
                    data: Theme.of(context),
                    child: Opacity(
                      opacity: t,
                      child: IosStyleToast(),
                    ),
                  );
                }, key: ValueKey('nihao'));
              },
              child: Text('show iOS Style Dialog'),
            )
          ])
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  final List<Widget> children;

  const _Section({Key key, @required this.title, @required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 16),
          _Title(title: title),
          Wrap(spacing: 8, children: children),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title;

  const _Title({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 10, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
    );
  }
}
