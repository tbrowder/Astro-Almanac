use Test;
use Astro::Almanac;

plan 1;

# Tests from Astronomical Algorithms:

# p. 347
my a-m = 134.6885; # right ascension, Moon
my d-m = +13.7684; # declination, Moon
my D   = 368_410;  # Earth-Moon, km

my a-s = 20.6579;  # Sun
my d-s = 8.6964;
my R   = 149_971_520; # km

is 1,1;

