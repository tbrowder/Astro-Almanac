[![Actions Status](https://github.com/tbrowder/Astro-Almanac/workflows/test/badge.svg)](https://github.com/tbrowder/Astro-Almanac/actions)

NAME
====

**Astro::Almanac** - Provides data on the paths of the Sun, Moon, and planets for a given location on the Earth

Requires installation of Perl module **Astro::Montenbruck, version 1.24+**.

**WARNING: THIS IS CURRENTLY NON-FUNCTIONAL FOR NORMAL USE BUT IS NEARING COMPLETION**

SYNOPSIS
========

```raku
use Astro::Almanac;
my $lat = 32.4;  # 32.4 degrees north latitude
my $lon = 86.2;  # 86.2 degrees west longitude
my $a   = Astro::Almanac.new: :$lat, :$lon;
# generate one month (Feb) of daily information in a single JSON file
my $file = '2022-02.json';
$a.generate :2022year, :2month, :$file;
# OUTPUT: «See output file '2022-02.json'␤»

# same for the entire year:
$file = '2022.json';
$a.generate :2022year, :$file;
# OUTPUT: «See output file '2022.json'␤»
```

Note that times for events are always expressed as UTC.

DESCRIPTION
===========

**Astro::Almanac** provides daily observation data (for a specific Earth surface location at sea level), on the Sun, Moon, and planets, all output as a JSON file named `astro-data-YYYY.json` (default name, but user-selectable).

Under the covers it uses several scripts from an excellent Perl module. To install the Perl module execute, as root: `cpanm Astro::Montenbruck`. Be sure the version is at least 1.24.

See also related modules by the same author:
============================================

  * [`DateTime::Locations`](https://github.com/tbrowder/DateTime-Location)

  * [`DateTime::Julian`](https://github.com/tbrowder/DateTime-Julian)

  * [`Calendar`](https://github.com/tbrowder/Calendar)

  * [`CalendarConverter`](https://github.com/tbrowder/CalendarConverter)

CREDITS
=======

The author is indebted to *Sergey Krushinsky*, the author of the wonderful aid for amateur astronomers, the Perl module **Astro::Montenbruck**, available on [CPAN](https://cpan.org). Sergey was very kind and helpful to me during my learning the rudiments of his module, and was always willing to listen to my suggestions as a novice user. His module, to me, is like a *Swiss Army Knife* for astronomers.

AUTHOR
======

Tom Browder (tbrowder@cpan.org)

COPYRIGHT and LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

