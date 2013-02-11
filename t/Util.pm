package LayoutInterface::Subclass;
use parent Image::Layout::LayoutInterface;
sub new { bless {}, shift }
1;

package t::Util;
use strict;
use warnings;
use Image::Layout;
use File::Temp ();

my @exports = qw/
    new_layout_interface
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

sub new_layout_interface { LayoutInterface::Subclass->new() }

sub new { Image::Layout->new(@_) }

sub new_layout { new()->_create_layout(@_) }

sub tempdir { File::Temp::tempdir(@_) }

1;
