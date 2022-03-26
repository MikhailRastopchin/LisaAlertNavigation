// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:angles/angles.dart';

import 'dms.dart';
import 'latlon_ellipsoidal.dart';
import 'vector3d.dart';


class LatLonNVectorEllipsoidal extends LatLonEllipsoidal
{
  LatLonNVectorEllipsoidal ({
    required final double lat,
    required final double lon,
    final double height = 0,
    final Datum datum = const Datum(ellipsoid: Ellipsoids.wGS84),
  }) : super(lat: lat, lon: lon, height: height, datum: datum);

  NorthEastDownVector deltaTo(final LatLonEllipsoidal point)
  {
    final c1 = toCartessian();
    final c2 = point.toCartessian();
    final sigmaC = c2.minus(c1);

    // get local (n-vector) coordinate frame
    final n1 = toNvector();
    final a = Vector3d(x: 0, y: 0, z: 1);// axis vector pointing to 90°N
    final d = n1.negate();// down (pointing opposite to n-vector)
    final e = a.cross(n1).unit();// east (pointing perpendicular to the plane)
    final n = e.cross(d);// north (by right hand rule)

    // rotation matrix is built from n-vector coordinate frame axes (using row vectors)
    final r = [
      [ n.x, n.y, n.z ],
      [ e.x, e.y, e.z ],
      [ d.x, d.y, d.z ],
    ];

    // apply rotation to δc to get delta in n-vector reference frame
    final sigmaN = Cartesian(
      x: r[0][0]*sigmaC.x + r[0][1]*sigmaC.y + r[0][2]*sigmaC.z,
      y: r[1][0]*sigmaC.x + r[1][1]*sigmaC.y + r[1][2]*sigmaC.z,
      z: r[2][0]*sigmaC.x + r[2][1]*sigmaC.y + r[2][2]*sigmaC.z,
    );

    return NorthEastDownVector(north: sigmaN.x, east: sigmaN.y, down: sigmaN.z);
  }

  LatLonEllipsoidal destinationPoint(final NorthEastDownVector delta)
  {
    // convert North-East-Down delta to standard x/y/z vector in coordinate frame of n-vector
    final sigmaN = Vector3d(x: delta.north, y: delta.east, z: delta.down);

    // get local (n-vector) coordinate frame
    final n1 = toNvector();
    final a = Vector3d(x: 0, y: 0, z: 1); // axis vector pointing to 90°N
    final d = n1.negate();           // down (pointing opposite to n-vector)
    final e = a.cross(n1).unit();    // east (pointing perpendicular to the plane)
    final n = e.cross(d);            // north (by right hand rule)

    // rotation matrix is built from n-vector coordinate frame axes (using column vectors)
    final r = [
      [ n.x, e.x, d.x ],
      [ n.y, e.y, d.y ],
      [ n.z, e.z, d.z ],
    ];

    // apply rotation to δn to get delta in cartesian (ECEF) coordinate reference frame
    final sigmaC = Cartesian(
      x: r[0][0]*sigmaN.x + r[0][1]*sigmaN.y + r[0][2]*sigmaN.z,
      y: r[1][0]*sigmaN.x + r[1][1]*sigmaN.y + r[1][2]*sigmaN.z,
      z: r[2][0]*sigmaN.x + r[2][1]*sigmaN.y + r[2][2]*sigmaN.z,
    );

    // apply (cartesian) delta to c1 to obtain destination point as cartesian coordinate
    final c1 = toCartessian();// convert this LatLon to Cartesian
    final v2 = c1.plus(sigmaC);// the plus() gives us a plain vector,..
    final c2 = Cartesian(x: v2.x, y: v2.y, z: v2.z); //need to convert it to Cartesian to get LatLon

    // return destination cartesian coordinate as latitude/longitude
    return c2.toLatLon();
  }

  NvectorEllipsoidal toNvector()
  {
    final ff = Angle.degrees(latitude).radians;
    final ll = Angle.degrees(longitude).radians;

    final sinFF = sin(ff);
    final cosFF = cos(ff);
    final sinLL = sin(ll);
    final cosLL = cos(ll);

    final x = cosFF * cosLL;
    final y = cosFF * sinLL;
    final z= sinFF;

    return NvectorEllipsoidal(x: x, y: y, z: z, height: height, datum: datum);
  }

  @override
  CartesianNVector toCartessian()
  {
    final cartessian = super.toCartessian();
    return CartesianNVector(x: cartessian.x, y: cartessian.y, z: cartessian.z);
  }
}


class NvectorEllipsoidal extends Vector3d
{
  final double height;
  final Datum datum;

  NvectorEllipsoidal({
    required final double x,
    required final double y,
    required final double z,
    this.height = 0.0,
    this.datum = const Datum(ellipsoid: Ellipsoids.wGS84)
  }) : super(x: x, y: y, z: z);

  LatLonNVectorEllipsoidal toLatLon()
  {
    final ff = atan2(z, sqrt(x * x + y * y));
    final ll = atan2(y, x);

    return LatLonNVectorEllipsoidal(
      lat: Angle.radians(ff).degrees,
      lon: Angle.radians(ll).degrees,
      height: height,
      datum: datum,
    );
  }

  CartesianNVector toCartessian()
  {
    final b = datum.ellipsoid.b;
    final f = datum.ellipsoid.f;

    final m = (1 - f) * (1 - f);// (1−f)² = b²/a²
    final n = b / sqrt(x * x / m + y * y / m + z * z);

    final xx = n * x / m + x * height;
    final yy = n * y / m + y * height;
    final zz = n * z + z *height;
    return CartesianNVector(x: xx, y: yy, z: zz);
  }

  @override
  String toString({final int dp = 3, final int dpHeight = 3})
  {
    final h = '${height >= 0 ? '+' : ''}${height.toStringAsFixed(dpHeight)}';
    return '[${x.toStringAsFixed(dp)},${y.toStringAsFixed(dp)},${z.toStringAsFixed(dp)}$h]';
  }
}


class CartesianNVector extends Cartesian
{
  CartesianNVector({
    required final double x,
    required final double y,
    required final double z,
  }) : super(x: x, y: y, z: z);

  NvectorEllipsoidal toNVector({
    final Datum datum = const Datum(ellipsoid: Ellipsoids.wGS84)
  })
  {
    final a = datum.ellipsoid.a;
    final f = datum.ellipsoid.f;

    final e12 = 2 * f - f * f;//e² =1st eccentricity squared ≡ (a²-b²)/a²
    final e14 = e12 *e12;// e⁴

    final p = (x * x + y * y) / (a * a);
    final q = z * z * (1 -e12) / (a * a);
    final r = (p + q - e14) / 6;
    final s = (e14 * p * q) / (4 *r * r * r);
    final t = pow(1 + s + sqrt(2 * s + s * s), 1 / 3).toDouble();
    final u = r * (1 + t + 1 / t);
    final v  = sqrt(u * u + e14 * q);
    final w = e12 * (u +v - q) / (2 * v);
    final k = sqrt(u + v + w * w) - w;
    final d = k * sqrt(x * x + y * y) / (k + e12);

    final tmp = 1 / sqrt(d * d + z * z);
    final xx = tmp * k / (k + e12) * x;
    final yy = tmp * k / (k + e12) * y;
    final zz = tmp * z;
    final h = (k + e12 - 1) / k * sqrt(d * d + z * z);

    return NvectorEllipsoidal(x: xx, y: yy, z: zz, height: h, datum: datum);
  }
}


class NorthEastDownVector
{
  static NorthEastDownVector fromDistanceBearingElevation({
    required final double distance,//Length of NED vector in metres.
    required final double bearing,//Bearing (in degrees from north) of NED vector .
    required final double elevation,//Elevation (in degrees from local coordinate frame horizontal) of NED vector.
  })
  {
    final ff = Angle.degrees(bearing).radians;
    final aa = Angle.degrees(elevation).radians;

    final sinFF = sin(ff);
    final cosFF = cos(ff);
    final sinAA = sin(aa);
    final cosAA = cos(aa);

    return NorthEastDownVector(
      north: cosFF * distance * cosAA,
      east: sinFF * distance * cosAA,
      down: - sinAA * distance,
    );
  }

  final double north;
  final double east;
  final double down;

  NorthEastDownVector({
    required this.north,
    required this.east,
    required this.down,
  });

  //расстояние между точками.
  double get lenght => sqrt(north * north + east * east + down * down);

  //азимут
  double get bearing
    => Dms.wrap360(Angle.radians(atan2(east, north)).degrees);

  double get elevation => - Angle.radians(asin(down / lenght)).degrees;


  @override
  String toString({final int dp = 0})
    => '[N:${north.toStringAsFixed(dp)},E:${east.toStringAsFixed(dp)},D:${down.toStringAsFixed(dp)}]';
}
