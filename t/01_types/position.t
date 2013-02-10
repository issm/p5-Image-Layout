use strict;
use warnings;
use Test::More;
use Image::Layout::Types qw/Position is_Position/;
use Data::Validator;

subtest 'ok' => sub {
    for my $v (
        [0, 0],
        [1.2, -3.4],
        ['10px', '20px'],
        ['10mm', '20cm'],
        ['10pt', '20pt'],
        ['10%w', '20%h'],
    ) {
        ok is_Position($v), "type of \"[@$v]\" is-a " . Position;
    }
};

subtest 'ng' => sub {
    for my $v (
        [],
        [0],
        [1, 2, 3],
        ['10%', '20%'],
    ) {
        ok ! is_Position($v), "type of \"[@$v]\" is-not-a " . Position;
    }
};

done_testing;
