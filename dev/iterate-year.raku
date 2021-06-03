# Raku algorithm to iterate over a calendar year by calendar days:

    my $year = 2022;
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
        =begin comment
        # put the desired code here:
        for 'all' -> $twilight {
            # ./script/riseset.pl --place=56N26 37E09 --date=1968-02-11 --timezone=UTC
            %*ENV<INTERP_NOLIMIT> = " $date ";
            shell "$pprog --place=$place --twilight={$twilight} --date={$date} --nolimit={$nolimit} --timezone=UTC";
        }
        =end comment
        # get the next day
        $d = $d.later(:1day);
    }
