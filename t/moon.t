use Test;
use Astro::Almanac;

use Math::Trig:auth<tbrowder:CPAN> :ALL;

plan 3;

# Tests from Astronomical Algorithms:

# p. 347
my $rha-m  = 134.6885; # degrees right ascension, Moon
my $decl-m = +13.7684; # degrees declination, Moon
my $D      = 368_410;  # Earth-Moon, km

my $rha-s  = 20.6579;  # Sun
my $decl-s = 8.6964;
my $R      = 149_971_520; # Earth-Sun, km

my $cos-psi = sind($decl-s) * sind($decl-m) + cosd($decl-s) * cosd($decl-m) * cosd($rha-s - $rha-m); # Eq. 48.2
my $psi     = acosd $cos-psi;
my $tan-i   = ($R * sind($psi)) / ($D - $R * $cos-psi); # Eq. 48.3
my $i       = atand $tan-i;
my $k       = (1 + cosd($i)) / 2; # Eq. 48.1
my $tan-chi = (cosd($decl-s) * sind($rha-s - $rha-m))
             / (sind($decl-s) * cosd($decl-m) - cosd($decl-s) * sind($decl-m) * cosd($rha-s - $rha-m)); # Eq. 48.5

is-approx $psi, 110.7929, "psi, degrees";
is-approx $i, 69.0756, "phase angle, degrees";
# round k to four decimal places
$k = sprintf('%0.4f', $k).Real;

is-approx $k, 0.6786, "fraction of illumination";

