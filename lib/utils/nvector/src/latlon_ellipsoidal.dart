// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:angles/angles.dart';

import 'dms.dart';
import 'vector3d.dart';

class Ellipsoid
{
  final num a;
  final num b;
  final num f;

  const Ellipsoid({required this.a, required this.b, required this.f});
}


abstract class Ellipsoids
{
  static const wGS84 = Ellipsoid(
    a: 6378137,
    b: 6356752.314245,
    f: 1 / 298.257223563
  );
}

class Datum
{
  final Ellipsoid ellipsoid;

  const Datum({required this.ellipsoid});
}


class LatLonEllipsoidal
{
  late double _lat;
  late double _lon;
  late double _height;

  late Datum _datum;

  LatLonEllipsoidal({
    required final double lat,
    required final double lon,
    final double height = 0,
    final Datum datum = const Datum(ellipsoid: Ellipsoids.wGS84)
  }) {
    _lat = Dms.wrap90(lat);
    _lon = Dms.wrap180(lon);
    _height = height;
    _datum = datum;
  }

  double get latitude => _lat;

  set latitude(final double value)
  {
    if (_lat == value) return;
    _lat = Dms.wrap90(value);
  }

  double get longitude => _lon;

  set longitude(final double value)
  {
    if (_lon == value) return;
    _lon = Dms.wrap180(value);
  }

  double get height => _height;

  set height(final double value)
  {
    if (_height == value) return;
    _height = value;
  }

  Datum get datum => _datum;

  set datum(final Datum value)
  {
    if (_datum == value) return;
    _datum = value;
  }

  Cartesian toCartessian()
  {
    final ff = Angle.degrees(_lat).radians;
    final l = Angle.degrees(_lon).radians;
    final h = height;
    final a = datum.ellipsoid.a;
    final f = datum.ellipsoid.f;

    final sinFF = sin(ff);
    final cosFF = cos(ff);
    final sinL = sin(l);
    final cosL = cos(l);

    final e12 = 2 * f - f * f;// 1st eccentricity squared ≡ (a²-b²)/a²
    final v = a / sqrt(1 - e12 * sinFF * sinFF);// radius of curvature in prime vertical

    final x = (v + h) * cosFF * cosL;
    final y = (v + h) * cosFF * sinL;
    final z = (v * (1 - e12) + h) * sinFF;

    return Cartesian(x: x, y: y, z: z);
  }

  bool equals(final LatLonEllipsoidal point)
  {
    const epsilon = 2.2204460492503130808472633361816 * 0.0000000000000001;
    if (
      (_lat - point.latitude).abs() > epsilon
      || (_lon - point.longitude).abs() > epsilon
      || (_height - point.height).abs() > epsilon
      || datum != point.datum
    ) return false;
    return true;
  }

  @override
  String toString({final int dp = 4, final int? dpHeight})
  {
    final height = (this.height >= 0 ? '+' : '-') + this.height.toStringAsFixed(dpHeight ?? 4) + 'm';
    final lat = Dms.toLat(_lat, dp);
    final lon = Dms.toLon(_lon, dp);
    return '$lat, $lon${dpHeight == null ? '' : height}';
  }
}


class Cartesian extends Vector3d
{
  Cartesian({
    required final double x,
    required final double y,
    required final double z,
  }) : super(x: x, y: y, z: z);

  LatLonEllipsoidal toLatLon({final Ellipsoid ellipsoid = Ellipsoids.wGS84})
  {
    final a = ellipsoid.a;
    final b = ellipsoid.b;
    final f = ellipsoid.f;

    final e12 = 2 * f - f * f;//1st eccentricity squared ≡ (a²−b²)/a²
    final e22 = e12 / (1 - e12);//2nd eccentricity squared ≡ (a²−b²)/b²
    final p = sqrt(x * x + y * y);// distance from minor axis
    final r = sqrt(p*p + z*z); // polar radius

    // parametric latitude (Bowring eqn.17, replacing tanβ = z·a / p·b)
    final tanB = (b * z) / (a * p) * (1 + e22 * b/r);
    final sinB = tanB / sqrt(1 + tanB * tanB);
    final cosB = sinB / tanB;

    // geodetic latitude (Bowring eqn.18: tanφ = z+ε²⋅b⋅sin³β / p−e²⋅cos³β)
    final ff = cosB.isNaN
      ? 0.0
      : atan2(z + e22 * b * sinB * sinB * sinB, p - e12 * a * cosB * cosB * cosB).toDouble();

    // longitude
    final l = atan2(y, x);

    // height above ellipsoid (Bowring eqn.7)
    final sinFF = sin(ff);
    final cosFF = cos(ff);
    final v = a / sqrt(1 -e12 * sinFF * sinFF); // length of the normal terminated by the minor axis // radius of curvature in prime vertical
    final h = p * cosFF + z * sinFF - (a * a / v);

    return LatLonEllipsoidal(
      lat: Angle.radians(ff).degrees,
      lon: Angle.radians(l).degrees,
      height: h
    );
  }
}
