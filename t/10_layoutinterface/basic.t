use strict;
use warnings;
use Test::More;
use t::Util;

my $if = new_layout_interface();

### properties
ok $if->can('pos');
ok $if->can('parent_pos');
ok $if->can('h_origin');
ok $if->can('v_origin');

### methods
ok $if->can('to_px');
ok $if->can('_mm');
ok $if->can('_pt');
ok $if->can('_layouts');
ok $if->can('_create_layout');
ok $if->can('settings');
ok $if->can('add_layout');

done_testing;
