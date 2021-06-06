#!/usr/bin/env raku

use JSON::Fast;

my $dir  = "./bin";
my $pha  = "$dir/phases.pl";
my $pos  = "$dir/planpos.pl";
my $ris  = "$dir/riseset_mod.pl";
#my $rst  = "$dir/rst_almanac.pl";
my $sol  = "$dir/solequ.pl";

# these data are for testing one month's worth of data
#my $loc   = "30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28
my $loc   = "30.3905 86.4646";
my $d     = Date.new(now);
my $year  = $d.year; #2022;
my $ofil  = "$year.json";

my $month;
my $date;

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

my $debug = 1; # during dev testing only
my $force = 0;

for @*ARGS {
    when /:i ^h/ {
        #shell("perl $rst --help > RST.help").so;
        shell("perl $sol --help > SOL.help").so;
        shell("perl $pos --help > POS.help").so;
        shell("perl $pha --help > PHA.help").so;
        shell("perl $ris --help > RIS.help").so;
        say "See 4 help files: xxx.help";
        exit;
    }
    when /:i ^d/ {
        $debug = 1;
    }
    when /:i ^f/ {
        $force = 1;
    }
    when /^ (\d**4 '-' \d\d '-' \d\d) $/ {
        $date = ~$0;
    }
    when /^ (\d**4) $/ {
        $year = +$0;
    }
    when /^ (\d) $/ {
        $month = +$0;
    }
    when /:i ^t/ {
        $date = Date.new(now);
    }

}

if 0 {
    say qq:to/HERE/;
    {$date ?? $date !! "\$date is nil"}
    HERE
    exit
}

# get the raw data
my $solfil = "{$year}-sol.txt";
my $phafil = "{$year}-pha.txt";
#my $rstfil = "{$year}-rst.txt";
my $posfil = "{$year}-pos.txt";
my $risfil = "{$year}-ris.txt";

gen-ris-txt :$year, :$month, :$date, :ofil($risfil), :$force, :$debug;
gen-sol-txt :$year, :ofil($solfil), :$force, :$debug;
gen-pha-txt :$year, :$month, :$date, :ofil($phafil), :$force, :$debug;

# convert to a hash
my %hash;
riseset_mod2hash :$year, :%hash, :ifil($risfil), :$force, :$debug;
phases2hash :$year, :%hash, :ifil($phafil), :$force, :$debug;
solstices2hash :$year, :%hash, :ifil($solfil), :$force, :$debug;

# the positions need the hash of rise/set event times
gen-pos-txt :$year, :%hash, :$month, :$date, :ofil($posfil), :$force, :$debug;

# calculate Moon position and fraction of illumination
# data from previously collected data

# save the hash as JSON
my $jstr = to-json %hash;
my $jfil = "{$year}.json";
spurt $jfil, $jstr;
say "Normal end.";
say "See output JSON file '$jfil'.";

#### subroutines ####
sub riseset_mod2hash(:$year!, :%hash!, :$ifil!, :$force, :$debug) {
    # uses output from riseset_mod.pl
    =begin comment
Date      :  2021-06-05 CDT
Place     :  51N28, 000W00
Time Zone :  America/Chicago

        rise       transit    set     
Moon    21:00:19   03:21:51   09:57:38   
...
Pluto   17:56:25   22:00:08   01:59:52   

Twilight: civil
Dawn   :  21:59:40
Dusk   :  15:58:01

Twilight: nautical
Dawn   :  20:50:36
Dusk   :  17:07:42

Twilight: astronomical
Dawn   :  --------
Dusk   :  --------
    =end comment

    my @lines = $ifil.IO.lines;

    my $date;
    my ($twilight, $dawn, $dusk);
    for @lines -> $line is copy {
        next if $line !~~ /\S/;
        next if $line ~~ /rise \h+ transit \h+ set/;

        if $line ~~ /^\h* Date/ {
            # beginning of a data block
            # Date      :  2022-01-01 UTC
            $date = $line.words[2];
        }
        elsif $line ~~ /^\h* Place/ {
            # Place     :  30N22, 086W28
            my $w = $line.words[2];
        }
        elsif $line ~~ /^\h* Time/ {
            # Time Zone :  UTC
            my $w = $line.words[3];
        }
        elsif $line ~~ /^\h* Twilight/ {
            # Twilight (civil)
            # Twilight (nautical)
            # Twilight (astronimical)
            $twilight = $line.words[1];
            $twilight ~~ s/'('//;
            $twilight ~~ s/')'//;
        }
        elsif $line ~~ /^\h* Dawn/ {
            # Dawn   :  12:16:02
            $dawn = $line.words[2];
        }
        elsif $line ~~ /^\h* Dusk/ {
            # end of a data block
            # Dusk   :  23:23:03
            $dusk = $line.words[2];
            # set the data in the hash
            %hash{$date}<twilight>{$twilight}<dawn> = "{$dawn}Z";
            %hash{$date}<twilight>{$twilight}<dusk> = "{$dusk}Z";
        }
        else {
            # a planet line
            #           rise      transit     set
            # Moon    11:33:36   16:43:07   21:49:51
            my @w = $line.words;
            my $planet  = @w[0];
            my $rise    = @w[1];
            my $transit = @w[2];
            my $set     = @w[3];
            # set the data in the hash
            %hash{$date}{$planet}<rise><time>    = "{$rise}Z";
            %hash{$date}{$planet}<transit><time> = "{$transit}Z";
            %hash{$date}{$planet}<set><time>     = "{$set}Z";
        }
    }
}

sub phases2hash(:$year!, :%hash!, :$ifil!, :$force, :$debug) {
    =begin comment
Date          :  2022-01-01
Time Zone     :  UTC

Last Quarter  :  2021-12-04 07:44:53
New Moon      :  2021-12-04 07:44:53
First Quarter :  2021-12-11 01:37:49
Full Moon     :  2021-12-19 04:37:21 *
New Moon      :  2022-01-02 18:36:04
    =end comment

    my @lines = $ifil.IO.lines;

}

sub solstices2hash(:$year!, :%hash!, :$ifil!, :$force, :$debug) {
    =begin comment
Year          :  2022
Time Zone     :  UTC

March equinox     :  2022-03-20 15:33:25
June solstice     :  2022-06-21 09:13:52
September equinox :  2022-09-23 01:03:27
December solstice :  2022-12-21 21:47:49
    =end comment

    my @lines = $ifil.IO.lines;
    my $Y = @lines.shift;
    if $Y.words[2] ne $year {
        die "FATAL: Wrong year in first line '$Y'";
    }
    my $tz = @lines.shift;
    die "FATAL: Unexpected second line '$tz'" if $tz.words[3] ne "UTC";

}

sub rst-almanac2hash(:$year!, :%hash!, :$ifil!, :$force, :$debug) {
    =begin comment
30N22, 086W28
Time Zone: UTC

2022-01-01
Moon         rise: 11:34, transit: 16:42, set: 21:50
...
Pluto        rise: 13:47, transit: 18:53, set: 23:58
    =end comment

    my @lines = $ifil.IO.lines;
    my $loc = @lines.shift;
    if $loc !~~ /[N|S] .+ [E|W] / {
        die "FATAL: Unexpected first line '$loc'";
    }
    my $tz = @lines.shift;
    die "FATAL: Unexpected second line '$tz'" if $tz.words[2] ne "UTC";

    my $date;
    for @lines -> $line is copy {
        next if $line !~~ /\S/;
        # remove commas from the line
        $line ~~ s:g/','//;
        my @w = $line.words;
        my $w = @w.shift;

        if $w ~~ /\d**4 '-' \d**2 '-' \d**2/ {
            $date = $w;
        }
        else {
            #                0     1     2        3    4     5
            # Mars         rise: 10:42 transit: 15:49 set: 20:55
            my $planet  = $w;
            my $rise    = @w[1];
            my $transit = @w[3];
            my $set     = @w[5];
            # set the data in the hash
            %hash{$date}{$planet}<rise><time>    = "{$rise}Z";
            %hash{$date}{$planet}<transit><time> = "{$transit}Z";
            %hash{$date}{$planet}<set><time>     = "{$set}Z";
        }
    }
}

=begin comment
sub gen-rst-txt(:$year!, :$ofil!, :$force, :$debug,
                :$date,  # one day of data
                :$month, # one month of data for month N
               ) {
    # normally do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else {
            say "File $ofil exists.";
            return;
        }
    }

    my ($days, $d0);
    if $date {
        $days = 1;
        shell "perl $rst --place=$loc --start=$date --timezone=UTC --days=$days > $ofil";
    }
    elsif $month {
        $d0 = Date.new(:$year, :$month);
        $days = $d0.days-in-month;
        shell "perl $rst --place=$loc --start=$year-01-01 --timezone=UTC --days=$days > $ofil";
    }
    else {
        $d0 = Date.new(:$year);
        $days = $d0.is-leap-year ?? 366 !! 365;
        shell "perl $rst --place=$loc --start=$year-01-01 --timezone=UTC --days=$days > $ofil";
    }
}
=end comment

sub gen-sol-txt(:$year!, :$ofil!, :$force, :$debug) {
    # do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else {
            say "File $ofil exists.";
            return;
        }
    }

    shell "perl $sol --no-colors --year=$year --timezone=UTC > $ofil";
}

sub gen-ris-txt(:$year!, :$ofil!, :$force, :$debug,
                :$date,  # one day of data
                :$month, # one month of data for month N
               ) {
    # uses riseset_mod.pl
    # normally do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else {
            say "File $ofil exists.";
            return;
        }
    }

    if $date {
        shell "perl $ris --no-colors --timezone=UTC --place=$loc --date=$date >> $ofil";
        return;
    }

    # set start day automatically
    my $d0;
    if $month {
        $d0 = Date.new(:$year, :$month);
    }
    else {
        $d0 = Date.new(:$year);
    }

    # end date
    my $d1;
    if $month {
        my $day = $d0.days-in-month;
        $d1 = Date.new(:$year, :$month, :day($day));
    }
    else {
        $d1 = Date.new(:$year, :12month, :31day);
    }

    # iterate over the days in the selected year or month
    my $d = $d0;
    while $d <= $d1 {
        note "DEBUG day of year: {$d.day-of-year}" if $debug;
        my $date = sprintf "%04d-%02d-%02d", $d.year, $d.month, $d.day;

        # put the desired code here:
        shell "perl $ris --no-colors --timezone=UTC --place=$loc --date=$date >> $ofil";

        # get the next day
        $d = $d.later(:1day);
    }
}

sub gen-pha-txt(:$year!, :$ofil!, :$force, :$debug,
                :$date,  # one day of data
                :$month, # one month of data for month N
               ) {
    # normally do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else {
            say "File $ofil exists.";
            return;
        }
    }

    if $date {
        shell "perl $pha --no-colors --timezone=UTC --date=$date  >> $ofil";
        return;
    }

    # set start day automatically
    my $d0;
    if $month {
        $d0 = Date.new(:$year, :$month);
    }
    else {
        $d0 = Date.new(:$year);
    }

    # end date
    my $d1;
    if $month {
        my $day = $d0.days-in-month;
        $d1 = Date.new(:$year, :$day);
    }
    else {
        $d1 = Date.new(:$year, :12month, :31day);
    }
    

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

sub gen-pos-txt(:$year!, :%hash!, :$ofil!, :$force, :$debug,
                :$date,  # one day of data
                :$month, # one month of data for month N
               ) {
    # normally do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else {
            say "File $ofil exists.";
            return;
        }
    }

    if $date {
        return;
    }
    elsif $month {
        return;
    }
}
