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

Under the covers it uses one fine Perl module thanks to the excellent Raku module `Inline::Perl5`. To install the Perl module execute:

    # cpanm Astro::Montenbruck

See also related modules by the same author:
============================================

  * [`DateTime::Locations`](https://github.com/tbrowder/DateTime-Location)

  * [`Calendar`](https://github.com/tbrowder/Calendar)

CREDITS
=======

The author is indebted to *Sergey Krushinsky*, the author of the excellent aid for amateur astronomers, the Perl module `Astro::Montenbruck`, available on [CPAN](https://cpan.org). Sergey was very kind and helpful to me during my learning the rudiments of his module, and was always willing to listen to my suggestions as a novice user. His module, to me, is like a *Swiss Army Knife* for astronomers.

AUTHOR
======

Tom Browder <tom.browder@cpan.org>

COPYRIGHT AND LICENSE
=====================

© 2021 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

