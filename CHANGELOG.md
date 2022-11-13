# Change Log

## 2.1.0
* toast now didn't interrupt pointer event anymore.

## 2.0.1

* compat with version before flutter3.

## 2.0.0

* update dart sdk min version to `2.14.0`.
* compat with flutter 3, fix null-aware operator unnecessary warning. [#76](https://github.com/boyan01/overlay_support/issues/76)
* update docs.

## 2.0.0-beta.0

* fix null-aware operator unnecessary warning. [#76](https://github.com/boyan01/overlay_support/issues/76)
* update dart sdk min version to `2.14.0`.
* remove pedantic dependency, replace with lint instead.

## 1.2.1

* added reverse animation duration and implicit parameter for
  animation. [#66](https://github.com/boyan01/overlay_support/pull/66)
  by [petro-i](https://github.com/petro-i)

## 1.2.0

* The same as 1.2.0-nullsafety.0.
* Recreate example.

## 1.0.5-hotfix1

* remove the deprecated method which from v1.12.x in BuildContext , fix #64

## 1.2.0-nullsafety.0

* Support multi OverlaySupport. add `OverlaySupport.local()` for local notification.

## 1.1.0-nullsafety.0

* migrate to nullsafety.

## 1.0.5

* Expose duration
  to `showSimpleNotification` [#46](https://github.com/boyan01/overlay_support/pull/46)
  by [Elvis Sun](https://github.com/elvisun)

## 1.0.4

* Support for `BottomSlideNotification`. [#40](https://github.com/boyan01/overlay_support/pull/40)
  by [Giles Correia Morton](https://github.com/gilescm)
* Upgrade min dart sdk version to
  2.1.0. [Policy](https://dart.dev/tools/pub/publishing#publishing-prereleases)

## 1.0.3

* expose toastTheme. by [juvs](https://github.com/juvs)

## 1.0.2

* fix Toast hidden behind ime #20

## 1.0.1

* swipe to dismiss #16
* adjust default toast background #18

## 1.0.0

* do not need to pass `context` parameter to popup overlay

## 0.3.0

* add key parameter for showOverlay

## 0.2.0

* fix: call NotificationEntry#dismiss immediately when we showNotification cause an exception

## 0.1.0

* expose showOverlay method to help build custom overlay
* mark autoDismiss param as Deprecate, replace by duration param

## 0.0.4

* bug fix

## 0.0.3

* bug fix

## 0.0.2

* remove line limit of toast

## 0.0.1

* support notification
* support toast
