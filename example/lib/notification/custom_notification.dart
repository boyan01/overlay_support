import 'package:flutter_web/material.dart';

const messages = [
  'Hey! What’s up?',
  'Do you want some chips with your sandwich?',
  'Do you want to see a movie?',
  'Do you like "OverlaySupport" library',
  'if you like it, please go to github give him a star',
  'https://github.com/boyan01/overlay_support',
];

class MessageNotification extends StatelessWidget {
  final VoidCallback onReplay;

  final String message;

  const MessageNotification({
    Key key,
    @required this.onReplay,
    @required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(
              size: const Size(40, 40),
              child: ClipOval(child: Image.asset('assets/avatar.png'))),
          title: Text('Boyan'),
          subtitle: Text(message),
          trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                ///TODO i'm not sure it should be use this widget' BuildContext to create a Dialog
                ///maybe i will give the answer in the future
                if (onReplay != null) onReplay();
              }),
        ),
      ),
    );
  }
}
