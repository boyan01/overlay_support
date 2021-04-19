# Chnage Log

## Next Version

* add your change here.

## 1.2.1 - 2021/4/19

* added reverse animation duration and implicit parameter for
  animation. [#66](https://github.com/boyan01/overlay_support/pull/66)
  by [petro-i](https://github.com/petro-i)

## 1.2.0 - 2021/3/14

* The same as 1.2.0-nullsafety.0.
* Recreate example.

## [1.0.5-hotfix1] - 20201/2/9

* remove the deprecated method which from v1.12.x in BuildContext , fix #64

## [1.2.0-nullsafety.0] - 2020/12/21

* Support multi OverlaySupport. add `OverlaySupport.local()` for local notificatiton.

## [1.1.0-nullsafety.0]

* migrate to nullsafety.

## [1.0.5] - 2020/7/20

* Expose duration
  to `showSimpleNotification` [#46](https://github.com/boyan01/overlay_support/pull/46)
  by [Elvis Sun](https://github.com/elvisun)

## [1.0.4] - 2020/5/26

* Support for `BottomSlideNotification`. [#40](https://github.com/boyan01/overlay_support/pull/40)
  by [Giles Correia Morton](https://github.com/gilescm)
* Upgrade min dart sdk version to
  2.1.0. [Policy](https://dart.dev/tools/pub/publishing#publishing-prereleases)

## [1.0.3] - 2020/3/13

* expose toastTheme. by [juvs](https://github.com/juvs)

## [1.0.2] - 2019/10/23

* fix Toast hidden behind ime #20

## [1.0.1] - 2019/7/26

* swipe to dismiss #16
* adjust default toast background #18

## [1.0.0] - 2019/6/16

* do not need pass `context` parameter to popup overlay

## [0.3.0] - 2019/5/22

* add key parameter for showOverlay

## [0.2.0] - 2019/5/15

* fix: call NotificationEntry#dismiss immediately when we showNotification cause an exception

## [0.1.0] - 2019/3/5

* expose showOverlay method to help build custom overlay
* mark autoDismiss param as Deprecate, replace by duration param

## [0.0.4] - 2019/3/2

* bug fix

## [0.0.3] - 2019/2/18

* bug fix

## [0.0.2] - 2019/2/17

* remove line limit of toast

## [0.0.1] - 2019/2/16

* support notification
* support toast
