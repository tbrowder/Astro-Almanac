#!/usr/bin/env raku

my $dir   = "./bin";
my $prog = "$dir/rst_almanac.pl";

my $loc = "30n23 86w28"; # Okaloosa County EMS: 30.3905;86.4646 == 30n23 86w28
my $Y = 2022;

for @*ARGS {
    when /h/ {
        shell "perl $prog --help";
        exit;
    }
}

# do a whole year's worth with one call
my $year = $Y;
# set start day automatically
my $d0 = Date.new(:$year);
my $days-in-year = $d0.is-leap-year ?? 366 !! 365;
shell "perl $prog --place=$loc --start=$Y-01-01 --timezone=UTC --days=$days-in-year";
