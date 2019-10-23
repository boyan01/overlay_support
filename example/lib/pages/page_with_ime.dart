import "package:flutter/material.dart";
import 'package:overlay_support/overlay_support.dart';

class PageWithIme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("toast with ime")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaisedButton(
              child: Text("show toast"),
              onPressed: () {
                toast("message");
              }),
          TextField(autofocus: true)
        ],
      ),
    );
  }
}
