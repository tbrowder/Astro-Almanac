unit class Astro::Almanac:ver<0.0.1>:auth<cpan:TBROWDER>;

=begin comment

structure of the hash of astro data
-----------------------------------

Note the season hash will have 
useful data only four days per year.

The value of most k/v pairs is local time (hhmmL - adjusted for DST).
The exceptions are:

  information - value is a string 
  location    - value is a string 
  event       - value is a string 
  fraction    - value is a decimal value in the range (0.00..1.00)

{
information
location
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
