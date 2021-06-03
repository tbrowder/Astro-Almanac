use Test;
use Astro::Almanac::Lawrence::Math;

plan 26;

is INT(1.5), 1;
is INT(1.4), 1;
is INT(-1.5), -2;
is INT(-1.4), -2;

is FIX(1.5), 1;
is FIX(1.4), 1;
is FIX(-1.5), -1;
is FIX(-1.4), -1;

is ABS(-5.0), 5;
is ABS(5.4), 5.4;
is ABS(0), 0;

is FRAC(1.5), 0.5;
is FRAC(-1.5), 0.5;

is -100 MOD 8, 4;
is -400 MOD 360, 320;
is 270 MOD 180, 90;
is -270.8 MOD 180, 89.2;
is 390 MOD 360, 30;
is 390.5 MOD 360, 30.5;
is -400 MOD 360, 320;

is ROUND(1.4), 1;
is ROUND(1.8), 2;
is ROUND(-1.4), -1;
is ROUND(-1.8), -2;

is SIGN(-3), -1;
is SIGN(3), 1;
