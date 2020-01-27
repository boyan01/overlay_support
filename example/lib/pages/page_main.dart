import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support_example/notification/custom_animation.dart';
import 'package:overlay_support_example/notification/custom_notification.dart';
import 'package:overlay_support_example/notification/ios_toast.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _Section(title: 'Notification', children: <Widget>[
          RaisedButton(
            onPressed: () {
              showSimpleNotification(
                Text("this is a message from simple notification"),
                background: Colors.green,
              );
            },
            child: Text(
              "Auto Dimiss Notification",
            ),
          ),
          RaisedButton(
            onPressed: () {
              showSimpleNotification(
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
                slideDismiss: true,
              );
            },
            child: Text("Fixed Notification"),
          )
        ]),
        _Section(title: 'Custom notification', children: <Widget>[
          RaisedButton(
            onPressed: () {
              showOverlayNotification((context) {
                return MessageNotification(
                  message: messages[3],
                  onReply: () {
                    OverlaySupportEntry.of(context).dismiss();
                    toast('you checked this message');
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
                await Future.delayed(Duration(milliseconds: 200 + random.nextInt(200)));
                showOverlayNotification((context) {
                  return MessageNotification(
                    message: messages[i],
                    onReply: () {
                      OverlaySupportEntry.of(context).dismiss();
                      toast('you checked this message');
                    },
                  );
                }, duration: Duration(milliseconds: 4000), key: const ValueKey('message'));
              }
            },
            child: Text('message sequence'),
          ),
        ]),
        _Section(title: 'toast', children: [
          RaisedButton(
            onPressed: () {
              toast('this is a message from toast');
            },
            child: Text('toast'),
          )
        ]),
        _Section(title: 'custom', children: [
          RaisedButton(
            onPressed: () {
              showOverlay((context, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: IosStyleToast(),
                );
              }, key: ValueKey('hello'));
            },
            child: Text('show iOS Style Dialog'),
          ),
          RaisedButton(
            onPressed: () {
              showOverlay((context, animation) {
                return CustomAnimationToast(animation: animation);
              }, key: ValueKey('hello'));
            },
            child: Text('show custom animation overlay'),
          ),
          RaisedButton(
            onPressed: () {
              showOverlay((context, animation) {
                return Stack(
                  children: <Widget>[
                    AnimatedModalBarrier(
                      color: ColorTween(begin: Colors.transparent, end: Colors.black54).animate(animation),
                      dismissible: false,
                    ),
                    SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation),
                      child: Column(
                        children: <Widget>[
                          MessageNotification(
                            message: "Hello",
                            onReply: () {
                              OverlaySupportEntry.of(context).dismiss();
                            },
                            key: ModalKey(const Object()),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }, duration: Duration.zero);
            },
            child: Text('show notification with barrier'),
          )
        ])
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  final List<Widget> children;

  const _Section({Key key, @required this.title, @required this.children}) : super(key: key);

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
