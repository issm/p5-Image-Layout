package MyLayout::Foobar;
use strict;
use warnings;
use parent 'Image::Layout::Base';
1;

package FooLayout::Foo;
use strict;
use warnings;
use parent 'Image::Layout::Base';
1;

package BarLayout::Bar::Bar;
use strict;
use warnings;
use parent 'Image::Layout::Base';
1;

package main;
use strict;
use warnings;
use Test::More;
use MouseX::Types::Mouse qw/is_Int/;
use Try::Tiny;
use t::Util;

subtest 'single' => sub {
    local @Image::Layout::LAYOUT_NAMESPACES;

    my $image = new();

    try {
        $image->add_layout( type => '+MyLayout::Foobar' );
        ok 'can add layout "+MyLayout::Foobar"';
        $image->add_layout( type => 'Foobar' );
        fail 'should have error.';
    } catch {
        ok 'cannot add layout "MyLayout::Foobar" as "Foobar"';
    };

    $image->add_layout_namespace( 'MyLayout' );

    try {
        $image->add_layout( type => 'Foobar' );
        ok 'can add layout "MyLayout::Foobar" as "Foobar"';
        $image->add_layout( type => '+MyLayout::Foobar' );
        ok 'can also add layout "+MyLayout::Foobar"';
    } catch {
        warn shift;
        fail 'should be able to add layout "MyLayout::Foobar" as "Foobar"';
    };
};

subtest 'multiple' => sub {
    local @Image::Layout::LAYOUT_NAMESPACES;

    my $image = new();

    $image->add_layout( type => '+FooLayout::Foo' );
    $image->add_layout( type => '+BarLayout::Bar::Bar' );
    ok 'can add layouts "+FooLayout::Foo" and "+BarLayout::Bar::Bar"';

    try {
        $image->add_layout( type => 'Foo' );
        fail 'should have error';
    } catch {
        ok 'cannot add layout "FooLayout::Foo" as "Foo"';
    };

    try {
        $image->add_layout( type => 'Bar' );
        fail 'should have error';
    } catch {
        ok 'cannot add layout "BarLayout::Bar::Bar" as "Bar"';
    };

    $image->add_layout_namespace(qw/ FooLayout BarLayout::Bar /);

    try {
        $image->add_layout( type => 'Foo' );
        ok 'can add layout "FooLayout::Foo" as "Foo"';
        $image->add_layout( type => 'Bar' );
        ok 'can add layout "BarLayout::Bar::Bar" as "Bar"';
    } catch {
        warn shift;
        fail 'should be able to add layout "FooLayout::Foo" as "Foo" and "BarLayout::Bar::Bar" as "Bar"';
    };
};

subtest 'available from "sublayout"?' => sub {
    local @Image::Layout::LAYOUT_NAMESPACES;

    my $image = new();
    $image->add_layout( type => 'Base' );
    my $l = $image->_layouts->[0];

    try {
        $l->add_layout( type => 'Foobar' );
        fail 'should have error';
    } catch {
        ok 'cannot add layout "MyLayout::Foobar" as "Foobar" from "sublayout"';
    };

    $image->add_layout_namespace( 'MyLayout' );

    try {
        $l->add_layout( type => 'Foobar' );
        ok 'can add layout "MyLayout::Foobar" as "Foobar" from "sublayout"';
    } catch {
        warn shift;
        fail 'should be able to add layout "MyLayout::Foobar" as "Foobar" from "sublayout"';
    };
};

done_testing;
