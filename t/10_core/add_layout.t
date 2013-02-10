use strict;
use warnings;
use Test::More;
use MouseX::Types::Mouse qw/is_Int/;
use Try::Tiny;
use t::Util;

subtest 'basic' => sub {
    my $image = new();
    isa_ok $image->add_layout(type => 'Base'), 'Image::Layout';
};


subtest 'position' => sub {
    subtest 'unit is available?' => sub {
        my $image = new()
            ->add_layout(
                type => 'Base',
                pos     => [ '10px', '20px' ],
                rel_pos => [ '10px', '20px' ],
            )
            ->add_layout(
                type => 'Base',
                pos     => [ '10mm', '20cm' ],
                rel_pos => [ '10mm', '20cm' ],
            )
            ->add_layout(
                type => 'Base',
                pos     => [ '10pt', '20pt' ],
                rel_pos => [ '10pt', '20pt' ],
            )
            ->add_layout(
                type    => 'Base',
                pos     => [ '10%w', '20%h' ],
                rel_pos => [ '10%w', '20%h' ],
            )
        ;
        ok $image;
    };

    subtest 'value' => sub {
        my $image = new()
            # 0
            ->add_layout(
                type => 'Base',
            )
            # 1
            ->add_layout(
                type => 'Base',
                pos  => [ 100, 200 ],
            )
            # 2
            ->add_layout(
                type    => 'Base',
                rel_pos => [ 50, 100 ],
            )
        ;

        my ($l0, $l1, $l2) = @{$image->_layouts};

        is_deeply $l0->parent_pos, [0, 0];
        is_deeply $l0->pos, [0, 0];

        is_deeply $l1->parent_pos, [0, 0];
        is_deeply $l1->pos, [100, 200];

        is_deeply $l2->parent_pos, [0, 0];
        is_deeply $l2->pos, [50, 100];
    };
};

done_testing;
