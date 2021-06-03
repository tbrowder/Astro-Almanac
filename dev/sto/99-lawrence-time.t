use Test;
use Astro::Almanac::Lawrence::TimeConversions :ALL;

plan 6;

my %t =
    0.27 => [6, 28, 48],
    0.78 => [18, 43, 12],
;

for %t.kv -> $k, $v {
    my ($hh, $mm, $ss) = $v;
    my ($h, $m, $s) = dayfrac2hms $k;

    is $h, $hh;
    is $m, $mm;
    is $s, $ss;
}

