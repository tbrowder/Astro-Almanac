#!/usr/bin/env raku

my $dir  = "./bin";
my $pha  = "$dir/phases.pl";
my $pos  = "$dir/planpos.pl";
my $rst  = "$dir/rst_almanac.pl";
my $sol  = "$dir/solequ.pl";

my $loc  = "30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28
my $year = 2022;
my $ofil = "$year.json";

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
    when /:i ^h/ {
        run("perl", "$rst --help".words).so;
        run("perl", "$sol --help".words).so;
        run("perl", "$pos --help".words).so;
        run("perl", "$pha --help".words).so;
        exit;
    }
    when /:i ^d/ {
        $debug = 1;
    }
    when /:i ^f/ {
        $force = 1;
    }
}

# get the raw data
my $solfil = "{$year}-sol.txt";
my $phafil = "{$year}-pha.txt";
my $rstfil = "{$year}-rst.txt";

gen-rst-txt :$year, :ofil($rstfil), :$force, :$debug;
gen-sol-txt :$year, :ofil($solfil), :$force, :$debug;
gen-pha-txt :$year, :ofil($phafil), :$force, :$debug;

# convert to a hash
my %hash;
rst-almanac2hash :$year, :%hash, :ifil($rstfil), :$force, :$debug;

phases2hash :$year, :%hash, :ifil($phafil), :$force, :$debug;
solstices2hash :$year, :%hash, :ifil($solfil), :$force, :$debug;

#say %hash;

# calculate Moon position and fraction of illumination
# data from prviously collected data

#### subroutines ####
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

sub gen-rst-txt(:$year!, :$ofil!, :$force, :$debug) {
    # do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else { 
            say "File $ofil exists.";
            return; 
        }
    }

    # set start day automatically
    my $d0 = Date.new(:$year);
    my $days-in-year = $d0.is-leap-year ?? 366 !! 365;
    shell "perl $rst --place=$loc --start=$year-01-01 --timezone=UTC --days=$days-in-year > $ofil";
}

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

sub gen-pha-txt(:$year!, :$ofil!, :$force, :$debug) {
    # do a whole year's worth with one call
    if $ofil.IO.f {
        if $force { unlink $ofil; }
        else { 
            say "File $ofil exists.";
            return; 
        }
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

