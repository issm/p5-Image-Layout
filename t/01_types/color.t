use strict;
use warnings;
use Test::More;
use Image::Layout::Types qw/Color is_Color/;
use Data::Validator;

subtest 'ok' => sub {
    for my $v (
        '#000000',
        '#abcdef',
        '#ABCDEF',
        '#00000000',
        '#abcdefab',
        '#ABCDEFAB',
    ) {
        ok is_Color($v), "type of \"$v\" is-a " . Color;
    }
};

subtest 'ng' => sub {
    for my $v (
        '',
        'foo',
        '#00000',    # 5-digits
        '#0000000',  # 7-digits
    ) {
        ok ! is_Color($v), "type of \"$v\" is-not-a " . Color;
    }
};

done_testing;
