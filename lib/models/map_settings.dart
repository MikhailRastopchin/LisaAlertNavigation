import 'package:latlong2/latlong.dart';


class MapSettings
{
  final bool useLocalMap;
  final LatLng? swPanBoundary;
  final LatLng? nePanBoundary;

  MapSettings({
    this.useLocalMap = false,
    this.swPanBoundary,
    this.nePanBoundary
  }) : assert(
    useLocalMap == false || (nePanBoundary != null && swPanBoundary != null)
  );

  factory MapSettings.fromJson(final Map<String, dynamic> jsonValue)
  {
    return MapSettings(
      useLocalMap: jsonValue['use_local_map'],
      swPanBoundary: LatLng.fromJson(jsonValue['sw']),
      nePanBoundary: LatLng.fromJson(jsonValue['ne']),
    );
  }

  Map<String, dynamic> toJson()
  {
    final jsonValue = <String, dynamic>{'use_local_map': useLocalMap};
    if (swPanBoundary != null) {
      jsonValue['sw'] = swPanBoundary!.toJson();
    }
    if (nePanBoundary != null) {
      jsonValue['ne'] = nePanBoundary!.toJson();
    }
    return jsonValue;
  }
}
