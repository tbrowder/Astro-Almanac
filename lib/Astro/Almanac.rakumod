unit class Astro::Almanac:ver<0.0.1>:auth<cpan:TBROWDER>;

=begin comment

structure of the hash of astro data
-----------------------------------

Note the season hash will have 
useful data only four days per year.

The value of most k/v pairs is local time (hhmmL - adjusted for DST)
The two exceptions are "event" whose value is a string and "fraction"
whose value is a decimal value in the range (0.00..1.00).
{
yyyy-mm-dd : { 
    season : {
        event
        time
    }
    <per planet> : {
        rise
        set
        transit
    }
    moon : {
        rise
        set
        transit
        fraction
    }
    sun : {
        rise
        set
        transit
        twilight : {
            astronomical
            civil
            nautical
        }
    }
}



=end comment
