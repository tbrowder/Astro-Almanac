[![Actions Status](https://github.com/tbrowder/Astro-Almanac/workflows/test-inline-perl5/badge.svg)](https://github.com/tbrowder/Astro-Almanac/actions)

NAME
====

`Astro::Almanac` - Provides data on the paths of the Sun, Moon, and planets

TEMPORARY DISCLAIMER
====================

`Astro::Almanac` is a Work in Progress (WIP). Please file an issue if there are any features you want added. Bug reports (issues) are always welcome.

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

`Astro::Almanac` provides daily observation data on the Sun, Moon, and planets, all output as a JSON file named `astro-data.json`.

Under the covers it uses three fine Perl modules thanks to the excellent Raku module `Inline::Perl5`. To install the Perl modules execute:

    # cpanm Astro::Montenbruck::RiseSet::RST
    # cpanm Astro::MoonPhase:
    # cpanm Astro::Utils

See also related modules by the same author:
============================================

  * [`DateTime::Locations`](https://github.com/tbrowder/DateTime-Location)

  * [`Calendar`](https://github.com/tbrowder/Calendar)

AUTHOR
======

Tom Browder <tom.browder@cpan.org>

COPYRIGHT AND LICENSE
=====================

© 2020 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

