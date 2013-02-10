package Image::Layout::Util;
use strict;
use warnings;
use Data::Validator;

my @exports = qw/validator/;

sub import {
    my $caller = caller;
    for my $f ( @exports ) {
        no strict 'refs';
        *{"$caller\::$f"} = \&$f;
    }
}

sub validator { Data::Validator->new(@_) }

1;
