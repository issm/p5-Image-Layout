package t::Util;
use strict;
use warnings;
use Image::Layout;

my @exports = qw/new/;

sub import {
    my $caller = caller;
    for my $f ( @exports ) {
        no strict 'refs';
        *{"$caller\::$f"} = \&$f;
    }
}

sub new { Image::Layout->new(@_) }

1;
