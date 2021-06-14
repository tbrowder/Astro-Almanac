use Test;
use Astro::Almanac;

use Math::Trig:auth<tbrowder:CPAN> :ALL;

plan 3;

# Tests from Astronomical Algorithms:

# p. 347
my $a-m = 134.6885; # right ascension, Moon
my $d-m = +13.7684; # declination, Moon
my $D   = 368_410;  # Earth-Moon, km

my $a-s = 20.6579;  # Sun
my $d-s = 8.6964;
my $R   = 149_971_520; # km

my $cos-psi = sind($d-s) * sind($d-m) + cosd($d-s) * cosd($d-m) * cosd($a-s - $a-m); # Eq. 48.2
my $psi     = acosd $cos-psi;
my $tan-i   = ($R * sind($psi)) / ($D - $R * $cos-psi); # Eq. 48.3
my $i       = atand $tan-i;
my $k       = (1 + cosd($i)) / 2; # Eq. 48.1
my $tan-chi = (cosd($d-s) * sind($a-s - $a-m))
             / (sind($d-s) * cosd($d-m) - cosd($d-s) * sind($d-m) * cosd($a-s - $a-m)); # Eq. 48.5

is-approx $psi, 110.7929, "psi, degrees";
is-approx $i, 69.0756, "phase angle, degrees";
# round k to four decimal places
$k = sprintf('%0.4f', $k).Real;

is-approx $k, 0.6786, "fraction of illumination";

