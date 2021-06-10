#!/perl

use 5.22.0;
use strict;
no warnings qw/experimental/;
use feature qw/switch/;

use utf8;
use FindBin qw/$Bin/;
use lib ("$Bin/../lib");
use Getopt::Long qw/GetOptions/;
use POSIX qw /floor/;
use Pod::Usage qw/pod2usage/;
use DateTime;
use Term::ANSIColor;

use Readonly;
use Astro::Montenbruck::Utils::Helpers
  qw/parse_datetime current_timezone local_now/;
use Astro::Montenbruck::Time qw/jd2cal jd2unix/;
use Astro::Montenbruck::Lunation qw/:all/;
use Astro::Montenbruck::Utils::Theme;

my $now = local_now();

my $help  = 0;
my $man   = 0;
my $date  = $now->strftime('%F');
my $tzone = current_timezone();
my @place;
my $theme = Astro::Montenbruck::Utils::Theme->create('colorless');

# Parse options and print usage if there is a syntax error,
# or if usage was explicitly requested.
GetOptions(
    'help|?'     => \$help,
    'man'        => \$man,
    'date:s'     => \$date,
    'theme:s'    => 
      sub { $theme = Astro::Montenbruck::Utils::Theme->create( $_[1] ) },
    'no-colors'  => 
      sub { $theme = Astro::Montenbruck::Utils::Theme->create('colorless') },      
    'timezone:s' => \$tzone,
) or pod2usage(2);

pod2usage(1)               if $help;
pod2usage( -verbose => 2 ) if $man;

# Initialize default options

$theme //= Astro::Montenbruck::Utils::Theme->create('dark');
my $scheme = $theme->scheme;

my $dt = parse_datetime($date);
$dt->set_time_zone($tzone) if defined $tzone;

$theme->print_data( 'Date', $dt->strftime('%F'), title_width => 14 );
$theme->print_data( 'Time Zone', $tzone,         title_width => 14 );
say();

# find New Moon closest to the date
my $j = search_event( [ $dt->year, $dt->month, $dt->day ], $NEW_MOON );

# if the event has not happened yet, find the previous one
if ( $j > $dt->jd ) {
    my ( $y, $m, $d ) = jd2cal( $j - 28 );
    $j = search_event( [ $y, $m, floor($d) ], $NEW_MOON );
}

my @month    = @MONTH;
my @quarters = ( { type => pop @month, jd => $j, current => 0 } );
push @month, $NEW_MOON;

for my $q (@month) {
    my ( $y, $m, $d ) = jd2cal $j;
    $j = search_event( [ $y, $m, floor($d) ], $q );
    my $prev = $quarters[$#quarters];
    $prev->{current} = 1 if ( $dt->jd >= $prev->{jd} && $dt->jd < $j );
    push @quarters, { type => $q, jd => $j, current => 0 };
}

for my $q (@quarters) {
    my $dt = DateTime->from_epoch( epoch => jd2unix( $q->{jd} ) )->set_time_zone($tzone);
    my $mark = $q->{current} ? '*' : ' ';
    my $data = sprintf( '%s %s', $dt->strftime('%F %T'), $mark );
   $theme->print_data(
        $q->{type}, $data,
        title_width => 14,
        highlited   => $q->{current}
    );
}

print "\n";
