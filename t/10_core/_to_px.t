use strict;
use warnings;
use Test::More;
use Image::Layout::Types qw/is_Position/;
use MouseX::Types::Mouse qw/is_Int/;
use Try::Tiny;
use t::Util;

my $image = new();

### ng
for my $args (
    [],
)  {
    try {
        $image->to_px( @$args );
        fail 'should have error.';
    } catch {
        my $msg = shift;
        ok $msg;
    };
}

### ok
for my $case (
    { arg => 100, expected => 100 },
    { arg => '10px' },
    { arg => '10mm' },
    { arg => '10cm' },
    { arg => '10pt' },
    { arg => '10%w' },
    { arg => '10%W' },
    { arg => '10%h' },
    { arg => '10%H' },

    { arg => '+100', expected => 100 },
    { arg => '+10px' },
    { arg => '+10mm' },
    { arg => '+10cm' },
    { arg => '+10pt' },
    { arg => '+10%w' },
    { arg => '+10%W' },
    { arg => '+10%h' },
    { arg => '+10%H' },

    { arg => '-100', expected => -100 },
    { arg => '-10px' },
    { arg => '-10mm' },
    { arg => '-10cm' },
    { arg => '-10pt' },
    { arg => '-10%w' },
    { arg => '-10%W' },
    { arg => '-10%h' },
    { arg => '-10%H' },

    { arg => 100.123, expected => 100.123 },
    { arg => '10.123px' },
    { arg => '10.123mm' },
    { arg => '10.123cm' },
    { arg => '10.123pt' },
    { arg => '10.123%w' },
    { arg => '10.123%W' },
    { arg => '10.123%h' },
    { arg => '10.123%H' },

    { arg => '+100.123', expected => 100.123 },
    { arg => '+10.123px' },
    { arg => '+10.123mm' },
    { arg => '+10.123cm' },
    { arg => '+10.123pt' },
    { arg => '+10.123%w' },
    { arg => '+10.123%W' },
    { arg => '+10.123%h' },
    { arg => '+10.123%H' },

    { arg => '-100.123', expected => -100.123 },
    { arg => '-10.123px' },
    { arg => '-10.123mm' },
    { arg => '-10.123cm' },
    { arg => '-10.123pt' },
    { arg => '-10.123%w' },
    { arg => '-10.123%W' },
    { arg => '-10.123%h' },
    { arg => '-10.123%H' },
) {
    my $px = $image->to_px( $case->{arg} );
    ok is_Int($px), qq{to_px("$case->{arg}") is-a Int};
    is $px, $case->{expected}  if defined $case->{expedted};
}

subtest 'type: Position' => sub {
    for my $case (
        { arg => [ 0, 0 ], expected => [ 0, 0 ] },
        { arg => [ '1px', '2px' ], expected => [ 1, 2 ] },
        { arg => [ '10mm', '20cm' ] },
        { arg => [ '10pt', '20pt' ] },
        { arg => [ '50%w', '50%h' ] },
    ) {
        my $pos_px = $image->to_px( $case->{arg} );
        ok is_Position($pos_px), qq{to_px([@{$case->{arg}}]) is-a Position};
        ok is_Int($pos_px->[0]);
        ok is_Int($pos_px->[1]);
        is_deeply $pos_px, $case->{expected}  if defined $case->{expedted};
    }
};

subtest 'a4 in mm: http://q.hatena.ne.jp/1175654835' => sub {
    my $image;
    my %geom = ( measure => 'mm', width => 210, height => 297 );

    $image = new( dpi => 72, %geom );
    ok abs($image->settings->width - 595) <= 1;
    ok abs($image->settings->height - 842) <= 1;

    $image = new( dpi => 150, %geom );
    ok abs($image->settings->width - 1240) <= 1;
    ok abs($image->settings->height - 1754) <= 1;

    $image = new( dpi => 300, %geom );
    ok abs($image->settings->width - 2480) <= 1;
    ok abs($image->settings->height - 3508) <= 1;

    $image = new( dpi => 600, %geom );
    ok abs($image->settings->width - 4961) <= 1;
    ok abs($image->settings->height - 7016) <= 1;
};

done_testing;
