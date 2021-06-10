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

use Readonly;
use Astro::Montenbruck::Utils::Helpers qw/parse_datetime local_now current_timezone/;
use Astro::Montenbruck::Utils::Theme;
use Astro::Montenbruck::Time qw/jd2unix/;
use Astro::Montenbruck::SolEqu qw/:all/;
use Astro::Montenbruck::Utils::Theme;

Readonly::Array our @EVT_NAMES => (
    'March equinox', 'June solstice', 'September equinox', 'December solstice');

my $now = my $now = local_now();

my $help   = 0;
my $man    = 0;
my $year   = $now->year;
my $tzone  = current_timezone(); # $now->strftime('%Z');
my $theme = Astro::Montenbruck::Utils::Theme->create('colorless');

# Parse options and print usage if there is a syntax error,
# or if usage was explicitly requested.
GetOptions(
    'help|?'     => \$help,
    'man'        => \$man,
    'year:i'     => \$year,
    'theme:s'    =>
      sub { $theme = Astro::Montenbruck::Utils::Theme->create( $_[1] ) },
    'no-colors'  => 
      sub { $theme = Astro::Montenbruck::Utils::Theme->create('colorless') },      
    'timezone:s' => \$tzone,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

# Initialize default options

$theme //= Astro::Montenbruck::Utils::Theme->create('dark');

$theme->print_data('Year', $year, title_width => 14);
$theme->print_data('Time Zone', $tzone, title_width => 14);
say();

for my $evt (@SOLEQU_EVENTS) {
    my $jd = solequ($year, $evt);
    my $dt = DateTime->from_epoch(epoch => jd2unix($jd))->set_time_zone($tzone); 
    $theme->print_data(
        $EVT_NAMES[$evt], 
        $dt->strftime('%F %T'), 
        title_width => 18,
        highlited => 1
    );
}

print "\n";
