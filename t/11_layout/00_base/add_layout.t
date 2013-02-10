use strict;
use warnings;
use Test::More;
use t::Util;

subtest 'basic' => sub {
    my $layout = new_layout( type => 'Base' );

    is scalar( @{ $layout->_layouts } ), 0;

    $layout->add_layout( type => 'Base' );
    is scalar( @{ $layout->_layouts } ), 1;
    isa_ok $layout->_layouts->[0], 'Image::Layout::Base';
};

subtest 'position' => sub {
    subtest 'parent_pos' => sub {
        my $l0 = new()->add_layout(
            type => 'Base'
        )->_layouts->[0];
        my $l1 = $l0->add_layout(
            type => 'Base',
            pos  => [ 100, 200 ],
        )->_layouts->[0];
        my $l2 = $l1->add_layout(
            type => 'Base',
            rel_pos => [ 50, 50 ],
        )->_layouts->[0];
        my $l3 = $l2->add_layout(
            type => 'Base',
            rel_pos => [ -10, -20 ],
        )->_layouts->[0];
        my $l4 = $l3->add_layout(
            type => 'Base',
            pos => [ 150, 100 ],
        )->_layouts->[0];

        is_deeply $l0->pos, [ 0, 0 ];
        is_deeply $l0->parent_pos, [ 0, 0 ];

        is_deeply $l1->pos, [ 100, 200 ];
        is_deeply $l1->parent_pos, [ 0, 0 ];

        is_deeply $l2->pos, [ 150, 250 ];
        is_deeply $l2->parent_pos, [ 100, 200 ];

        is_deeply $l3->pos, [ 140, 230 ];
        is_deeply $l3->parent_pos, [ 150, 250 ];

        is_deeply $l4->pos, [ 150, 100 ];
        is_deeply $l4->parent_pos, [ 140, 230 ];
    };
};

done_testing;
