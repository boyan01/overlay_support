import 'package:flutter/material.dart';
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
          _Section(
            title: 'Notification',
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  showSimpleNotification(context,
                      Text("this is a message from simple notification"),
                      background: Colors.green);
                },
                child: Text("simple Auto Dismiss"),
              ),
              RaisedButton(
                onPressed: () {
                  NotificationEntry entry;
                  entry = showSimpleNotification(
                    context,
                    Text("you got a simple message"),
                    trailing: FlatButton(
                        textColor: Colors.yellow,
                        onPressed: () {
                          entry.dismiss();
                        },
                        child: Text('Dismiss')),
                    background: Colors.green,
                    autoDismiss: false,
                  );
                },
                child: Text("simple fixed"),
              ),
              RaisedButton(
                onPressed: () {
                  NotificationEntry entry;
                  entry = showOverlayNotification(context, (_) {
                    return MessageNotification(
                      onReplay: () {
                        entry.dismiss();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text('message'),
                              );
                            });
                      },
                    );
                  }, duration: Duration(milliseconds: 4000));
                },
                child: Text('custom message notification'),
              ),
            ],
          ),
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
                });
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
