use strict;
use warnings;
use Test::More;
use t::Util;
use Image::Layout;

my $image = Image::Layout->new();
isa_ok $image, 'Image::Layout';

### inherit from LayoutInterface
ok $image->can('pos');
ok $image->can('parent_pos');
ok $image->can('to_px');
ok $image->can('_mm');
ok $image->can('_pt');
ok $image->can('_layouts');
ok $image->can('_create_layout');
ok $image->can('settings');
ok $image->can('add_layout');

is_deeply $image->_layouts, [];

done_testing;
