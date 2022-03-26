import 'dart:math';

import 'package:angles/angles.dart';


class Vector3d
{
  final double x;
  final double y;
  final double z;

  Vector3d({required this.x, required this.y, required this.z});

  double get length => sqrt(x * x + y * y + z * z);

  Vector3d plus(final Vector3d other)
    => Vector3d(x: x + other.x, y: y + other.y, z: z + other.z);

  Vector3d minus(final Vector3d other)
    => Vector3d(x: x - other.x, y: y - other.y, z: z - other.z);

  Vector3d times(final num number)
    => Vector3d(x: x * number, y: y * number, z: z * number,
    );

  Vector3d dividedBy(final num number)
    => Vector3d(x: x / number, y: y / number, z: z / number);

  double dot(final Vector3d other) => x * other.x + y * other.y + z * other.z;

  Vector3d cross(final Vector3d other)
    => Vector3d(
      x: y * other.z - z * other.y,
      y: z * other.x - x * other.z,
      z: x * other.y - y * other.x,
    );

  Vector3d negate() => Vector3d(x: - x, y: - y, z: - z);

  Vector3d unit()
  {
    final norm = length;
    if (norm == 1 || norm == 0) return this;
    return Vector3d(x: x / norm, y: y / norm, z: z / norm);
  }

  double angleTo(final Vector3d other, final Vector3d? planeNormal)
  {
    final sign = planeNormal == null || cross(other).dot(planeNormal) >= 0
      ? 1
      : - 1;
    final sinF = cross(other).length * sign;
    final cosF = dot(other);
    return atan2(sinF, cosF);
  }

  Vector3d rotateAround(final Vector3d axis, final double angle)
  {
    final F = Angle.degrees(angle).radians;

    final p = unit();
    final a = axis.unit();

    final s = sin(F);
    final c = cos(F);
    final t = 1 - c;

    final x = a.x;
    final y = a.y;
    final z = a.z;

    final r = [
      [ t * x * x + c,        t * x * y - s * z,    t * x * z + s * y ],
      [ t * x * y + s * z,    t * y * y + c,        t * y * z - s * x ],
      [ t * x * z - s * y,    t * y * z + s * x,    t * z * z + c     ]
    ];

    final rp = [
      r[0][0] * p.x + r[0][1] * p.y + r[0][2] * p.z,
      r[1][0] * p.x + r[1][1] * p.y + r[1][2] * p.z,
      r[2][0] * p.x + r[2][1] * p.y + r[2][2] * p.z,
    ];

    return Vector3d(x: rp[0], y: rp[1], z: rp[2]);
  }

  @override
  String toString({final int dp = 3})
    // ignore: lines_longer_than_80_chars
    => '${x.toDouble().toStringAsFixed(dp)},${y.toDouble().toStringAsFixed(dp)},${z.toDouble().toStringAsFixed(dp)},';
}

