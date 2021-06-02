#!/usr/bin/env raku
use Astro::Almanac::Lawrence::Math :ALL;
use Astro::Almanac::Lawrence::TimeConversions :ALL;

my $julianday = 2459285.1430445;
say jd2utc($julianday).Str; # Output: 2021-03-11T15:25:59.04Z


