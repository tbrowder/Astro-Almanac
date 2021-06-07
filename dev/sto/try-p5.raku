#!/usr/bin/env raku

use Astro::Montenbruck::Ephemeris::Planet::Moon:from<Perl5>;
use Astro::Montenbruck::Ephemeris::Planet::Sun:from<Perl5>;

use Astro::Montenbruck::CoCo:from<Perl5>;
use Astro::Montenbruck::Lunation:from<Perl5>;
use Astro::Montenbruck::Time:from<Perl5> qw/:all/;

=begin comment
my $jd = cal2jd 2021, 2, 21.4;
say "jd for 2021-02-21.4 is $jd";
=end comment

=begin comment
my $et = t2dt $jd;
say "ephemeral time for jd $jd is $et";
=end comment

=begin comment
my $mjd = jd2mjd $jd;
say "mjd for 2021-02-21.4 is $mjd";

$jd = mjd2jd $mjd;
say "jd for mjd $mjd is $jd";

my $jd0 = jd0 $jd;
say "jd at midnight for jd $jd is $jd0";

my $jdcent = jd_cent $jd;
say "jd_cent for jd $jd is $jdcent";

my $t1900 = t1900 $jd;
say "t1900 for jd $jd is $t1900";

my $jdgst = jd2gst $jd;
say "True Greenwich Sidereal Time for jd $jd is $jdgst";

# need to get Unix time in seconds from date and time
my $unix = DateTime.new("2021-02-21T13:04:31.245Z").posix;
say "unix (posix) time for input is $unix";

#my $loc = "30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28
my $long = 86 + 28/60; #"30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28

my $jdlst = jd2lst $jd, $long;
say "True Local Sidereal Time for jd $jd and longitude $long is $jdlst";
=end comment

my $jd = cal2jd 2021, 6, 7.4;
my $jdcent = jd_cent $jd;
# get Sun and Moon positions to calc crescent angle
# Output are heleocentric ecliptical coordinates of longitude (arc degrees), latitude (arc degrees),
# and distance from the Earth in AU (astronautical units)
my $m = Astro::Montenbruck::Ephemeris::Planet::Moon.new;
my @geo = $m.moonpos($jdcent);
say "x,y,z for the Moon at jdcent $jdcent is {@geo.raku}";
my ($x,$y,$z) = @geo;
my $s = Astro::Montenbruck::Ephemeris::Planet::Sun.new;
@geo = $s.sunpos($jdcent);
say "x,y,z for the Sun at jdcent $jdcent is {@geo.raku}";

# replicate values from simple_ephem.pl with same inputs:
$jd = 2458630.5; # Standard Julian date for May 27, 2019, 00:00 UTC.
my $t  = ($jd - 2451545) / 36525; # Convert Julian date to centuries since epoch 2000.0
use Astro::Montenbruck::Ephemeris:from<Perl5> qw/find_positions/;
my @PLANETS = 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars',
              'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto';
find_positions($t, @PLANETS, sub {
    my ($id, $lambda, $beta, $alpha) = @_;
    say "$id lambda: $lambda, beta: $beta, alpha: $alpha";
});

=finish

# try to get riseset info
use Astro::Montenbruck::RiseSet::Constants:from<Perl5>
  qw/:altitudes :twilight :events :states/;
use Astro::Montenbruck::RiseSet:from<Perl5> qw/rst twilight/;

# create function for calculating rise/set/transit events for
#  year for Niceville (30.485092, -86.4376157).
my $func = rst(
    date   => [2021, 3, 6],
    phi    => 30.485,
    lambda => -87.437,
);

sub jd2utc($jd) {
    my $frac = $jd - $jd.truncate;
    my $utc = ($frac - 0.5) * 24.0;
    $utc += 24 if $utc < 0;
    $utc
}

# alternatively, call the function in list context:
#for @PLANETS {
for "Sun" {
    my %res = $func.($_); # result structure is described below
    my $rjd = %res<rise><jd>;
    my $sjd  = %res<set><jd>;
    my $rcst = jd2utc($rjd) - 6;
    my $scst = jd2utc($sjd) - 6;

    say "rise: $rcst";
    say "set:  $scst";

    #say "$_: rise: {%res<rise><jd>}, transit: {%res<transit><jd>}, set: {%res<set><jd>}";
    #say %res.raku;
}

=finish

my $TWILIGHT_ASTRO = 'astronomical';
my $TWILIGHT_NAUTICAL = 'nautical';
my $TWILIGHT_CIVIL = 'civil';
for $TWILIGHT_ASTRO, $TWILIGHT_NAUTICAL, $TWILIGHT_CIVIL {
    # calculate twilightS
    my %res = twilight(
        type => $_,
        date       => [1989, 3, 23],
        phi        => 48.1,
        lambda     => -11.6,
        on_event   => sub {
            my ($evt, $jd) = @_;
            #say "$evt: $jd";
        },
        on_noevent => sub {
            my $state = shift @_;
            #say $state;
        }
    );
    say "twilight: $_: dawn: {%res<rise>}, dusk: {%res<set>}";
}

say "Lunation:";
my @M = 'New Moon', 'First Quarter', 'Full Moon', 'Last Quarter';
use Astro::Montenbruck::Lunation:from<Perl5> qw/:all/;
for @M {
    my @jd = search_event([2021, 3, 1], $_);
    say "  $_ at jd = {@jd.head}";
}

say "Solstices/equinoxes:";
use Astro::Montenbruck::SolEqu:from<Perl5> qw/:all/;
my @E = 'March equinox', 'June solstice', 'September equinox', 'December solstice';
for 0 .. 3 -> $i {
    my @jd = solequ(2021, $i);
    say "  {@E[$i]} at jd = {@jd.head}";

}

# try to get nautical twilight that fails on script/riseset.pl:
#   perl ./script/riseset.pl --no-colors --place=30n23 86w28 \
#       --date=2022-01-12 --timezone=UTC
#
# need phi and lambda for the location (place)
#   phi    - geographical latitude, degrees, positive northward
#   lambda - geographical longitude, degrees, positive westward

use Astro::Montenbruck::Utils::Helpers:from<Perl5> qw/parse_geocoords/;
my ($phi, $lambda) = parse_geocoords("30n23", "86w28");
say "DEBUG: phi for '30n23' = $phi";
say "DEBUG: lambda for '86w28' = $lambda";

#=finish

for $TWILIGHT_NAUTICAL {
    # calculate twilightS
    my %res = twilight(
        type => $_,
        date       => [2022, 1, 12],
        phi        => $phi,
        lambda     => $lambda,
        on_event   => sub {
            my ($evt, $jd) = @_;
            #say "$evt: $jd";
        },
        on_noevent => sub {
            my $state = shift @_;
            #say $state;
        }
    );
    #say "twilight: $_: dawn: {%res<rise>}, dusk: {%res<set>}";
    say %res.raku;
}

#### subroutines from Lawrence book
