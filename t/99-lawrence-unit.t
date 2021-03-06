use Test;
use Astro::Almanac::Lawrence::UnitConversions :ALL;

plan 14;

my $sign = 1;
my $h = 1;
my $m = 0;
my $s = 0;
my $t1 = '10:00:00';
my $t2 = '10:25:11';
my $t3 = '10h25m11s';
my $t4 = '-10:00:00';
my $t5 = '-10:25:11';
my $t6 = '-10h25m11s';
my $t7 = '13d04m10s';
my $t8 = '300d20m00s';

is dms2decimal($sign, $h, $m, $s), 1;
is dms2decimal(-1, $h, $m, $s), -1;

is dms2decimal($t1), 10;
is dms2decimal($t2), 10.419722;
is dms2decimal($t3), 10.419722;

is dms2decimal($t4), -10;
is dms2decimal($t5), -10.419722;
is dms2decimal($t6), -10.419722;
is dms2decimal($t7), 13.069444;
is dms2decimal($t8), 300.333333;

my $rad-str = sprintf "%0.6f", 180 * deg2rad;
my $deg-str = sprintf "%0.6f", 2.5 * rad2deg;
is '3.141593', $rad-str;
is '143.239449', $deg-str;

# time/longitude
is time2angle(2), 30.0;
is angle2time(156.3), 10.42;

# decimal2dms
