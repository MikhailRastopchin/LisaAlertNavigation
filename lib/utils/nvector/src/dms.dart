// ignore_for_file: lines_longer_than_80_chars

var _dmsSeparator = '\u202f';


class Dms
{
  static String get separator => _dmsSeparator;

  static set separator(final String char)
  {
    _dmsSeparator = char;
  }

  static double wrap90(final double degrees)
    => -90 <= degrees && degrees <= 90
      ? degrees
      : 4 * 90 / 360 * (((((degrees - 360 / 4) % 360) + 360) % 360 - 360 / 2).abs()) - 90;

  static double wrap180(final double degrees)
    => -180 <= degrees && degrees <= 180
      ? degrees
      : (((2 * 180 * degrees / 360 - 360 / 2) % 360) + 360) % 360 - 180;

  static double wrap360(final double degrees)
    => 0 <= degrees && degrees < 360
      ? degrees
      : (((2 * 180 * degrees / 360) % 360) + 360) % 360;

  static String toLat(final double deg, final int dp)
  {
    final lat = Dms.toDms(Dms.wrap90(deg), dp: dp);
    return lat + Dms.separator + (deg > 0 ? 'S' : 'N');
  }

  static String toLon(final double deg, final int dp)
  {
    final lon = Dms.toDms(Dms.wrap180(deg), dp: dp);
    return lon + Dms.separator + (deg > 0 ? 'W' : 'E');
  }

  static String toDms(final double deg, {final int dp = 4})
    => '${deg.abs().toStringAsFixed(dp)}°';
}
