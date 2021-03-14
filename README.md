# overlay_support

[![Pub](https://img.shields.io/pub/v/overlay_support.svg)](https://pub.dev/packages/overlay_support)
[![Pub](https://img.shields.io/pub/v/overlay_support.svg?include_prereleases)](https://pub.dev/packages/overlay_support)
[![CI](https://github.com/boyan01/overlay_support/workflows/CI/badge.svg)](https://github.com/boyan01/overlay_support/actions)
[![codecov](https://codecov.io/gh/boyan01/overlay_support/branch/master/graph/badge.svg)](https://codecov.io/gh/boyan01/overlay_support)

Provider support for `overlay`, make it easy to build **toast** and **In-App notification**.

**this library support ALL platform**

## Interaction

If you want to see the ui effect of this library, just click
here [https://boyan01.github.io/overlay_support/#/](https://boyan01.github.io/overlay_support/#/)

## How To Use

1. add dependencies into you project `pubspec.yaml` file

    ```yaml
    dependencies:
        overlay_support: latest_version
    ```

    * Current latest_version
      is [![Pub](https://img.shields.io/pub/v/overlay_support.svg)](https://pub.dev/packages/overlay_support)

> For project without migrate to null safety, please use version `overlay_support: 1.0.5-hotfix1`

2. wrap your AppWidget with `OverlaySupport`

```dart #build()
  return OverlaySupport.global(child: MaterialApp());
```

3. show toast or simple notifications

```dart
import 'package:overlay_support/overlay_support.dart';

void onClick() {
    // popup a toast.
    toast('Hello world!');

    // show a notification at top of screen.
    showSimpleNotification(
        Text("this is a message from simple notification"),
        background: Colors.green);
}
```

more instructions check here :  [example/README.md](./example/README.md)

## License

see License File

## End

if you have some suggestion or advice, please open an issue to let me known. This will greatly help
the improvement of the usability of this project. Thanks.
