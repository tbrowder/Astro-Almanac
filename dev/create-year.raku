#!/usr/bin/env raku

my $dir  = "./bin";
my $pha  = "$dir/phases.pl";
my $pos  = "$dir/planpos.pl";
my $rst  = "$dir/rst_almanac.pl";
my $sol  = "$dir/solequ.pl";

my $loc  = "30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28
my $year = 2022;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} y=YYYY id=NAME dir=DIRNAME lat=LATITUDE lon=LONGITUDE | help

    Files are written to directory DIRNAME which must exist.
    The id NAME is used in each output files' name.
    Temporary files are written to a system temp directory
        but are not deleted by the program. The temp
        directory path is output during the process.
    HERE
    exit;
}

my $debug = 0;
my $force = 0;

for @*ARGS {
    when /h/ {
        run("perl", "$rst --help".words).so;
        run("perl", "$sol --help".words).so;
        run("perl", "$pos --help".words).so;
        run("perl", "$pha --help".words).so;
        exit;
    }
}

# get the raw data
gen-rst-txt :$year, :$force, :$debug;
gen-sol-txt :$year, :$force, :$debug;
gen-pha-txt :$year, :$force, :$debug;

# convert to JSON
phases2json :$year, :$force, :$debug;
solstices2json :$year, :$force, :$debug;
rst-almanac2json :$year, :$force, :$debug;


# calculate Moon position and fraction of illumination
# data from prviously collected data

#### subroutines ####
sub phases2json(:$year!, :$force, :$debug) {
}
sub solstices2json(:$year!, :$force, :$debug) {
}
sub rst-almanac2json(:$year!, :$force, :$debug) {
}

sub gen-rst-txt(:$year!, :$force, :$debug) {
    # do a whole year's worth with one call
    my $ofil = "{$year}-rst.txt";
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else { return; }
    }

    # set start day automatically
    my $d0 = Date.new(:$year);
    my $days-in-year = $d0.is-leap-year ?? 366 !! 365;
    shell "perl $rst --place=$loc --start=$year-01-01 --timezone=UTC --days=$days-in-year > $ofil";
}

sub gen-sol-txt(:$year!, :$force, :$debug) {
    # do a whole year's worth with one call
    my $ofil = "{$year}-sol.txt";
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else { return; }
    }

    shell "perl $sol --no-colors --year=$year --timezone=UTC > $ofil";
}

sub gen-pha-txt(:$year!, :$force, :$debug) {
    # do a whole year's worth with one call
    my $ofil = "{$year}-pha.txt";
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else { return; }
    }

    # set start day automatically
    my $d0 = Date.new(:$year);

    # end date
    my $d1 = Date.new(:$year, :12month, :31day);
    my $days-in-year = $d0.is-leap-year ?? 366 !! 365;

    # iterate over the days in the selected year
    my $d = $d0;
    while $d <= $d1 {
        note "DEBUG day of year: {$d.day-of-year}" if $debug;
        my $date = sprintf "%04d-%02d-%02d", $d.year, $d.month, $d.day;

        # put the desired code here:
        shell "perl $pha --no-colors --timezone=UTC --date=$date  >> $ofil";

        # get the next day
        $d = $d.later(:1day);
    }
}

