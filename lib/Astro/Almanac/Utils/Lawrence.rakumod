unit module Astro::Almanac::Utils::Lawrence;

#| Some utility functions from J. L. Lawrence's
#| book "Celestial Calculations."

#| See p. 7
sub INT($x) is export {
    return $x.floor
}

#| See p. 7
sub FIX($x) is export(:FIX, :MATH) {
    return $x.Int    
}

#| See p. 7
sub ABS($x) is export {
    return $x.abs    
}

#| See p. 7
sub FRAC($x) is export {
    return abs($x - $x.Int) 
}

#| See p. 7
sub infix:<MOD>($x,$y) is export {
    # note that we want to allow Real numbers for $x
    return $x % $y;
}

#| See p. 8
sub ROUND($x) is export {
    return $x.round
}



