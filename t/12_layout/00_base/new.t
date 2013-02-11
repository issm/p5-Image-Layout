use strict;
use warnings;
use Test::More;
use t::Util;

subtest 'basic' => sub {
    my $l = new_layout(type => 'Base');
    ok $l->can('content');

    ### inherit from LayoutInterface
    ok $l->can('pos');
    ok $l->can('parent_pos');
    ok $l->can('to_px');
    ok $l->can('_mm');
    ok $l->can('_pt');
    ok $l->can('_layouts');
    ok $l->can('_create_layout');
    ok $l->can('settings');
    ok $l->can('add_layout');

    is_deeply $l->_layouts, [];
};

subtest 'with parameters' => sub {
    my $l = new_layout(
        type    => 'Base',
        pos     => [1, 2],
        content => 'foobar'
    );
    is_deeply $l->pos, [1, 2];
    is $l->content, 'foobar';
};

done_testing;
