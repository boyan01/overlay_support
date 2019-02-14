import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() => runApp(MyApp());

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
          SizedBox(height: 16),
          _Title(title: "Notification"),
          Wrap(
            spacing: 8,
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
            ],
          )
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
