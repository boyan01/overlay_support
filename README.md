# overlay_support 
[![Pub](https://img.shields.io/pub/v/overlay_support.svg)](https://pub.dartlang.org/packages/overlay_support)
[![CI](https://github.com/boyan01/overlay_support/workflows/CI/badge.svg)](https://github.com/boyan01/overlay_support/actions)
[![codecov](https://codecov.io/gh/boyan01/overlay_support/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/overlay_support)


provider support for overlay, easy to build **toast** and **internal notification**.

**this library support platform Android、iOS 、Linux、macOS、Windows and Web**

## Interation

If you want to see the ui effect of this library, just click here [https://boyan01.github.io/overlay_support/#/](https://boyan01.github.io/overlay_support/#/)

## How To Use

1. add dependencies into you project pubspec.yaml file
```
dependencies:
  overlay_support: latest_version
```
2. wrap your AppWidget with `OverlaySupport`
```dart #build()
  return OverlaySupport(child: MaterialApp());
```

3. show toast or simple notifications

```dart
//popup a toast
toast('Hello world!');

//show a notification at top of screen
showSimpleNotification(
    Text("this is a message from simple notification"),
    background: Colors.green);
```

more instructions check here :  [example/readme.md](./example/)

## License 

see License File

## End

if you have some suggestion or advice, please open an issue to let me known. 
This will greatly help the improvement of the usability of this project.
Thanks.
