use strict;
use warnings;
use Test::More;
use Image::Layout::Types qw/Unit is_Unit/;
use Data::Validator;

subtest 'ok' => sub {
    for my $v (
        123, +123, -123, 123.45, +123.45, -123.45,
        qw/123 +123 -123 123.45 +123.45 -123.45/,
        qw/123px 123mm 123cm 123pt 123%w 123%W 123%h 123%H/,
    ) {
        ok is_Unit($v), "type of \"$v\" is-a " . Unit;
    }
};

subtest 'ng' => sub {
    for my $v (
        '', qw/foo bar/,
        qw/123em 123m/,
    ) {
        ok ! is_Unit($v), "type of \"$v\" is-not-a " . Unit;
    }
};

done_testing;
