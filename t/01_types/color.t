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
    ) {
        ok is_Color($v), "type of \"$v\" is-a " . Color;
    }
};

subtest 'ng' => sub {
    for my $v ('', qw/foo bar/) {
        ok ! is_Color($v), "type of \"$v\" is-not-a " . Color;
    }
};

done_testing;
