import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

/// A widget that builds its child.
/// The same as [KeyedSubtree]
class KeyedOverlay extends StatelessWidget {
  final Widget child;

  const KeyedOverlay({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// [showOverlay] with block other show with the same [ModalKey].
///
/// for example
/// ```dart
/// final modalKey = ModalKey('simple');
///
/// //popup a simple message on top of screen
/// showSimpleNotification(Text('modal example'), key: modalKey);
///
/// //when previous notification is showing, popup again whit this key
/// //this notification will be rejected.
/// showSimpleNotification(Text('modal example 2'), key: modalKey);
///
/// ```
class ModalKey<T> extends ValueKey<T> {
  ModalKey(T value) : super(value);

  @override
  bool operator ==(other) {
    return other is ModalKey<T> && value == other.value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

///
/// The [OverlaySupportEntry] associated with [TransientKey] will be dismiss immediately
/// when next [OverlaySupportEntry] showing by [showOverlay] with the same key.
///
/// This key was designed for [toast], but it seems wired, so have not use yet.
///
/// For example:
/// ```dart
///
/// final key = const TransientKey('transient');
///
/// showSimpleNotification(Text('modal example'), key: key);
///
/// // The previous notification will be dismiss immediately, instead of have
/// // a disappearing animation effect.
/// showSimpleNotification(Text('modal example 2'), key: key);
///
/// ```
class TransientKey<T> extends ValueKey<T> {
  const TransientKey(T value) : super(value);

  @override
  bool operator ==(other) {
    return other is TransientKey<T> && value == other.value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}
