package t::Util;
use strict;
use warnings;
use Image::Layout;
use File::Temp ();

my @exports = qw/
    new
    new_layout
    tempdir
/;

sub import {
    my $caller = caller;
    for my $f ( @exports ) {
        no strict 'refs';
        *{"$caller\::$f"} = \&$f;
    }
}

sub new { Image::Layout->new(@_) }

sub new_layout { new()->_create_layout(@_) }

sub tempdir { File::Temp::tempdir(@_) }

1;
