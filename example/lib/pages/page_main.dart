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
          ElevatedButton(
            onPressed: () {
              showSimpleNotification(
                Text('this is a message from simple notification'),
                background: Colors.green,
              );
            },
            child: Text(
              'Auto Dismiss Notification',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showSimpleNotification(
                Text('you got a simple message'),
                trailing: Builder(builder: (context) {
                  return TextButton(
                      onPressed: () {
                        OverlaySupportEntry.of(context)!.dismiss();
                      },
                      child: Text('Dismiss',
                          style: TextStyle(color: Colors.amber)));
                }),
                background: Colors.green,
                autoDismiss: false,
                slideDismissDirection: DismissDirection.up,
              );
            },
            child: Text('Fixed Notification'),
          ),
          ElevatedButton(
            child: Text('Bottom Notification'),
            onPressed: () {
              showSimpleNotification(
                Text('Hello'),
                position: NotificationPosition.bottom,
                slideDismissDirection: DismissDirection.down,
              );
            },
          )
        ]),
        _Section(title: 'Custom notification', children: <Widget>[
          ElevatedButton(
            onPressed: () {
              showOverlayNotification((context) {
                return MessageNotification(
                  message: messages[3],
                  onReply: () {
                    OverlaySupportEntry.of(context)!.dismiss();
                    toast('you checked this message');
                  },
                );
              }, duration: Duration(milliseconds: 4000));
            },
            child: Text('custom message notification'),
          ),
          ElevatedButton(
            onPressed: () async {
              final random = Random();
              for (var i = 0; i < messages.length; i++) {
                await Future.delayed(
                    Duration(milliseconds: 200 + random.nextInt(200)));
                showOverlayNotification((context) {
                  return MessageNotification(
                    message: messages[i],
                    onReply: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                      toast('you checked this message');
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
          ElevatedButton(
            onPressed: () {
              toast('this is a message from toast');
            },
            child: Text('toast'),
          )
        ]),
        _Section(title: 'custom', children: [
          ElevatedButton(
            onPressed: () {
              showOverlay((_, t) {
                return Theme(
                  data: Theme.of(context),
                  child: Opacity(
                    opacity: t,
                    child: IosStyleToast(),
                  ),
                );
              }, key: ValueKey('hello'));
            },
            child: Text('show iOS Style Dialog'),
          ),
          ElevatedButton(
            onPressed: () {
              showOverlay((context, t) {
                return CustomAnimationToast(value: t);
              }, key: ValueKey('hello'), curve: Curves.decelerate);
            },
            child: Text('show custom animation overlay'),
          ),
          ElevatedButton(
            onPressed: () {
              showOverlay((context, t) {
                return Container(
                  color: Color.lerp(Colors.transparent, Colors.black54, t),
                  child: FractionalTranslation(
                    translation: Offset.lerp(
                        const Offset(0, -1), const Offset(0, 0), t)!,
                    child: Column(
                      children: <Widget>[
                        MessageNotification(
                          message: 'Hello',
                          onReply: () {
                            OverlaySupportEntry.of(context)!.dismiss();
                          },
                          key: ModalKey(const Object()),
                        ),
                      ],
                    ),
                  ),
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

  const _Section({Key? key, required this.title, required this.children})
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

  const _Title({Key? key, required this.title}) : super(key: key);

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
