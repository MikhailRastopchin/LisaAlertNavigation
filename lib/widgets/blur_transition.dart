import 'dart:ui';

import 'package:flutter/widgets.dart';


class BlurTransition extends AnimatedWidget
{
  final Widget? child;
  final Animation<double> sigma;

  const BlurTransition({
    final Key? key,
    required this.sigma,
    this.child
  })
  : super(key: key, listenable: sigma);

  @override
  Widget build(final BuildContext context) =>
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma.value, sigmaY: sigma.value),
      child: child,
    );
}
