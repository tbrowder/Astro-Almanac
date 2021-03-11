unit module Astro::Almanac::Lawrence::TimeConversions;

use Astro::Almanac::Lawrence::Math;
use Astro::Almanac::Lawrence::UnitConversions :ALL;

#| Some time conversion functions from J. L. Lawrence's
#| book "Celestial Calculations."
#| Chapters 2 and 3

#| decimal hours to hms
#| See p. 18
sub dayfrac2hms($x --> List) is export(:dayfrac2hms) {
    # hours must be a fraction of a day of 24 hours     
    die "FATAL: Input \$x ($x) must be >= 0 and < 1" if not (0 <= $x < 1);
    my $hreal = 24 * $x;
    my $h = INT $hreal;
    my $m = INT 60 * FRAC($hreal);
    my $s = 60 * FRAC(60 * FRAC($hreal));
    $h, $m, $s;
}



