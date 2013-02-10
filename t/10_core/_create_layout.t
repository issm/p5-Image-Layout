package My::Layout::FooBar;
use parent 'Image::Layout::Base';
1;

package main;
use strict;
use warnings;
use Test::More;
use t::Util;

my $image = new();

subtest 'base' => sub {
    my $l = $image->_create_layout( type => 'Base' );
    isa_ok $l, 'Image::Layout::Base';
};

subtest 'my type' => sub {
    my $l = $image->_create_layout( type => '+My::Layout::FooBar' );
    isa_ok $l, 'My::Layout::FooBar';
};

done_testing;
