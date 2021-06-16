unit class Astro::Almanac:ver<0.0.1>:auth<cpan:TBROWDER>;

use Math::Trig:auth<tbrowder:CPAN> :ALL;

has $.year;
has %.data; # See dev/JSON.schema for the layout. 



sub moon-data(:$rha-sun!, 
              :$decl-sun!, 
              :$dist-sun!, 
              :$rha-moon!, 
              :$decl-moon!,
              :$dist-moon!, 
              :$lat,
              :$lon,
              :$debug,
              --> List
             ) is export {
    # input angles are in decimal degrees
    # input distances from Astro::Montenbruck are in AU
    # returns a list:
    #   zenith angle, degrees
    #   fraction of illumination

    my \R = $dist-sun;
    my \D = $dist-moon;

    # psi is the geometric elongation of the Moon from the Sun
    my $cos-psi = sind($decl-sun) * sind($decl-moon) + cosd($decl-sun) * cosd($decl-moon) * cosd($rha-sun - $rha-moon); # Eq. 48.2
    my $psi     = acosd $cos-psi;

    # iota is the phase angle for a geocentric observer
    my $tan-iota = (R * sind($psi)) / (D - R * $cos-psi); # Eq. 48.3
    my $num   = (R * sind($psi)); #  / (D - R * $cos-psi); # Eq. 48.3
    my $denom = (D - R * $cos-psi); # Eq. 48.3

    my $iota2    = atand $tan-iota;
    my $iota     = atan2d $num, $denom;

    # the angles psi and iota are always between 0 and 180 degrees

    # illuminated fraction
    my $k       = (1 + cosd($iota)) / 2; # Eq. 48.1

    # chi is the position angle (PA) of the Moon's bright limb
    my $tan-chi = (cosd($decl-sun) * sind($rha-sun - $rha-moon))

    # Note chi is NOT measured from the direction of the observer's zenith.
    # The zenith angle is chi - q where q is the parallactic angle (see Chapter 14).

    my $tan-q = sind(H) / (tand(phi) * cosd(delta) - sind(delta) *  cosd(H)); # Eq. 14.1

  where:

  phi - geographical latitude of the observer
  delta - declination of the celestial body
  H     - the body's hour angle at the given instant

}






