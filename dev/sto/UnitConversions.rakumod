unit module Astro::Almanac::Lawrence::UnitConversions;

use Astro::Almanac::Lawrence::Math :ALL;

#| Some unit conversion functions from J. L. Lawrence's
#| book "Celestial Calculations."
#| Chapter 2

# Astronautical unit (p. 15)
constant AU      is export = 149_597_870_700; # meters
constant deg2rad is export = pi/180;
constant rad2deg is export = 180/pi;

# Decimal format conversions (p. 15)
# 
# HMS format for time:   xHyMzS (hour, minute, seconds)
# DMS format for angles: xDyMzS (degrees, minutes, seconds)

# DMS conversion to decimal for angles will also work for time
# See p. 17
multi sub dms2decimal(Real $sign, Real $h is copy, Real $m is copy = 0, Real $s is copy = 0) is export {
    $m += $s/60;
    $h += $m/60;
    return $h * $sign;
}

multi sub dms2decimal(Str $x is copy) is export {
    my $sign = 1;
    if $x ~~ /^ '-' / {
        $x ~~ s/^'-'//;
        $sign = -1;
    }

    if $x ~~ / (\d+) ':' (\d\d) ':' (\d\d['.'\d+]?) $/ {
        my $h = ~$0;
        my $m = ~$1;
        my $s = ~$2;
        # remove leading zeroes
        while $h ~~ /^0 <[1..9]>/ {
            $h ~~ s/^0//;
        }
        $m ~~ s/^0//;
        $s ~~ s/^0//;
        return dms2decimal $sign, $h.Real, $m.Real, $s.Real;
    }
    elsif $x ~~ /:i (\d+) ['h'|'d'] (\d\d) 'm' (\d\d ['.' \d+]? ) 's' $/ {
        my $h = ~$0;
        my $m = ~$1;
        my $s = ~$2;
        # remove leading zeroes
        while $h ~~ /^0 <[1..9]>/ {
            $h ~~ s/^0//;
        }
        $m ~~ s/^0//;
        $s ~~ s/^0//;
        return dms2decimal $sign, $h.Real, $m.Real, $s.Real;
    }
    die "FATAL: Unknown DMS format: $x";
}

#| See p. 18,
multi sub decimal2dms($x) is export {
}


#| See p. 
sub angle2time($degrees) is export {
    return $degrees / 15;
}

#| See p. 
sub time2angle($hours) is export {
    return $hours * 15;
}


