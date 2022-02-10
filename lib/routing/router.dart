import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as toasts;

import '../pages/common/styles.dart';
import '../widgets/blur_transition.dart';
import 'routes.dart';


abstract class Routing
{
  static toasts.ToastFuture showToast(final String text, {
    final BuildContext? context,
    Duration? animDuration,
    Duration? duration,
  })
  {
    animDuration ??= AppStyle.toasts.animDuration;
    duration ??= AppStyle.toasts.duration;
    final totalDuration = animDuration * 2 + duration;
    final borderRadius = AppStyle.toasts.borderRadius;
    return toasts.showToast(text,
      context: context,
      animationBuilder: (context, controller, duration, child) {
        final size = MediaQuery.of(context).size;
        final scale = Tween<double>(begin: 1.2, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine
          ),
        );
        final sigma = Tween<double>(begin: 0.0, end: 5.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine
          ),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInSine,
            reverseCurve: Curves.easeOutSine
          ),
        );
        return ScaleTransition(
          scale: scale,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BlurTransition(
              sigma: sigma,
              child: FadeTransition(
                opacity: opacity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width - 64.0),
                  child: child,
                ),
              ),
            )
          )
        );
      },
      toastHorizontalMargin: 0.0,
      animDuration: animDuration,
      duration: totalDuration,
    );
  }

  static void hideToasts()
  {
    toasts.ToastManager().dismissAll();
  }

  static Future showHome(final BuildContext context) async
  {
    return Navigator.of(context).pushNamed(Routes.home);
  }

  static Future<void> replaceWith(
    final BuildContext context,
    final String routeName,
    {
      Object? arguments
    }
  ) async
  {
    await Navigator.of(context).pushReplacementNamed(routeName,
      arguments: arguments
    );
  }

  static bool goBack(final BuildContext context, [ final dynamic result ])
  {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
      return true;
    }
    return false;
  }

  static void goHome(final BuildContext context)
  {
    Navigator.popUntil(context, ModalRoute.withName(Routes.home));
  }

  static void goOut()
  {
    SystemNavigator.pop();
  }
}
