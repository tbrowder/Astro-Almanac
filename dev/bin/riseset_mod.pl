#!/perl

use 5.22.0;
use strict;
no warnings qw/experimental/;
use feature qw/switch/;

use utf8;
use FindBin qw/$Bin/;
use lib ("$Bin/../lib");
use Getopt::Long qw/GetOptions/;
use Pod::Usage qw/pod2usage/;
use DateTime;
use Term::ANSIColor;

use Astro::Montenbruck::MathUtils qw/frac hms/;
use Astro::Montenbruck::Ephemeris::Planet qw/@PLANETS/;
use Astro::Montenbruck::Time qw/jd2unix cal2jd/;
use Astro::Montenbruck::RiseSet::Constants
  qw/:altitudes :twilight :events :states/;
use Astro::Montenbruck::RiseSet qw/rst twilight/;
use Astro::Montenbruck::Utils::Helpers
  qw/parse_datetime parse_geocoords format_geo hms_str local_now current_timezone @DEFAULT_PLACE/;
use Astro::Montenbruck::Utils::Theme;

binmode( STDOUT, ":encoding(UTF-8)" );

sub print_rst_row {
    my ( $obj, $res, $tzone, $theme ) = @_;
    my $sch = $theme->scheme;
    print $theme->decorate( sprintf( '%-8s', $obj ), $sch->{table_row_title} );

    for my $key (@RS_EVENTS) {
        my $evt = $res->{$key};
        if ( $evt->{ok} ) {
            my $dt = DateTime->from_epoch( epoch => jd2unix( $evt->{jd} ) )
              ->set_time_zone($tzone);
            print $theme->decorate( $dt->strftime('%T'),
                $sch->{table_row_data} );
        }
        else {
            print $theme->decorate( sprintf( '%-8s', ' — ' ),
                $sch->{table_row_error} );
        }
        print "   ";
    }
    print("\n");
}

sub print_twilight_row {
    my ( $evt, $res, $tzone, $theme ) = @_;
    my $sch = $theme->scheme;

    if ( exists $res->{$evt} ) {
        my $dt = DateTime->from_epoch( epoch => jd2unix( $res->{$evt} ) )
          ->set_time_zone($tzone);
        $theme->print_data( $TWILIGHT_TITLE{$evt}, $dt->strftime('%T'),
            title_width => 7 );
    }
    else {
        $theme->print_data( $TWILIGHT_TITLE{$evt}, ' --------', title_width => 7 );      
    }
}

my $now = local_now();

my $man   = 0;
my $help  = 0;
my $date  = $now->strftime('%F');
my $tzone = current_timezone();
my @place;
my $twilight = $TWILIGHT_NAUTICAL;
my $theme = Astro::Montenbruck::Utils::Theme->create('colorless');

# Parse options and print usage if there is a syntax error,
# or if usage was explicitly requested.
GetOptions(
    'help|?'     => \$help,
    'man'        => \$man,
    'date:s'     => \$date,
    'timezone:s' => \$tzone,
    'place:s{2}' => \@place,
    'theme:s'    =>
      sub { $theme //= Astro::Montenbruck::Utils::Theme->create( $_[1] ) },
    'no-colors'  => 
      sub { $theme = Astro::Montenbruck::Utils::Theme->create('colorless') },
    'twilight:s' => \$twilight
) or pod2usage(2);

pod2usage(1)               if $help;
pod2usage( -verbose => 2 ) if $man;

# Initialize default options
$theme //= Astro::Montenbruck::Utils::Theme->create('dark');
my $scheme = $theme->scheme;

@place = @DEFAULT_PLACE unless @place;

my $local = parse_datetime($date);
$local->set_time_zone($tzone) if defined($tzone);
$theme->print_data( 'Date', $local->strftime('%F %Z'), title_width => 10 );
my $utc =
    $local->time_zone ne 'UTC'
  ? $local->clone->set_time_zone('UTC')
  : $local;

my ( $lat, $lon );

# first, check if geo-coordinates are given in decimal format
if ( grep( /^[\+\-]?(\d+(\.?\d+)?|(\.\d+))$/, @place ) == 2 ) {
    ( $lat, $lon ) = @place;
}
else {
    ( $lat, $lon ) = parse_geocoords(@place);
}

$theme->print_data( 'Place',     format_geo( $lat, $lon ), title_width => 10 );
$theme->print_data( 'Time Zone', $tzone,                   title_width => 10 );

print "\n";
say $theme->decorate( "        rise       transit    set     ",
    $scheme->{table_row_title} );

# build top-level function for any event and any celestial object
# for given time and place
my $rst_func = rst(
    date   => [ $utc->year, $utc->month, $utc->day ],
    phi    => $lat,
    lambda => $lon
);

print_rst_row( $_, { $rst_func->($_) }, $tzone, $theme ) for (@PLANETS);


# mod from Sergey
for my $tw_type (qw/civil nautical astronomical/) {
    say $theme->decorate( "\nTwilight: $tw_type", $scheme->{data_row_title} );
    my %twl = twilight(
        date   => [ $utc->year, $utc->month, $utc->day ],
        phi    => $lat,
        lambda => $lon,
        type   => $tw_type,
    );
    print_twilight_row( $_, \%twl, $tzone, $theme ) for ( $EVT_RISE, $EVT_SET );
}

print "\n";
