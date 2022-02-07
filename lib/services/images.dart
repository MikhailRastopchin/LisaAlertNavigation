import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ImagesService
{
  const ImagesService();

  SvgPicture logo({
    final Color? color,
    final double? width,
    final double? height,
    final BoxFit fit = BoxFit.contain,
  }) => SvgPicture.asset(_logo,
    color: color, width: width, height: height, fit: fit,
  );

  Future<void> init() async
  {
    for (var svgAsset in [
      _logo,
    ]) {
      await precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoder, svgAsset), null,
      );
    }
  }

  Future<void> precache() async
  {
  }

  final _logo = 'assets/images/logo.svg';
}
