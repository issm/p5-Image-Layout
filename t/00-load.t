use 5.008;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Image::Layout' ) || print "Bail out!\n";
}

diag( "Testing Image::Layout $Image::Layout::VERSION, Perl $], $^X" );
