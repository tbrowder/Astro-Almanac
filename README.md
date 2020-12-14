[![Actions Status](https://github.com/tbrowder/Astro-Almanac/workflows/test/badge.svg)](https://github.com/tbrowder/Astro-Almanac/actions)

NAME
====

`Astro::Almanac` - Provides data on the paths of the Sun, Moon, and planetsth

SYNOPSIS
========

```raku
use Astro::Almanac;
use DateTime::Location;

my $loc = DateTime::Location.new: :$name, :$lat, :$lon, :$timezone;
my $a   = Astro::Almanac.new;

# generate one month of daily information in a single JSON file
$a.generate :$loc, :2021year, :1month;

# same for the entire year:
$a.generate :$loc, :2021year;
```

DESCRIPTION
===========

`Astro::Almanac` under the covers uses three fine Perl modules thanks to the excellent Raku module `Inline::Perl5`.

To install the Perl modules execute:

    # cpanm Astro::Montenbruck::RiseSet::RST
    # cpanm Astro::MoonPhase:
    # cpanm Astro::Utils

AUTHOR
======

Tom Browder <tom.browder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

