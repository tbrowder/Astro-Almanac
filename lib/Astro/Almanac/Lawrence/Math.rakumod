unit module Astro::Almanac::Lawrence::Math;

#| Some math functions from J. L. Lawrence's
#| book "Celestial Calculations."
#| Chapter 1

#| See p. 7
sub INT($x) is export {
    return $x.floor
}

#| See p. 7
sub FIX($x) is export {
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
    # so use the '%' operator
    return $x % $y;
}

#| See p. 8
sub ROUND($x) is export {
    return $x.round
}

sub SIGN($x) is export {
    return sign $x
}



