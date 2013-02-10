use strict;
use warnings;
use Test::More;
use Image::Layout::Types qw/Measure is_Measure/;
use Data::Validator;

subtest 'ok' => sub {
    for my $v (qw/px mm cm pt/) {
        ok is_Measure($v), "type of \"$v\" is-a " . Measure;
    }
};

subtest 'ng' => sub {
    for my $v ('', qw/foo bar m/) {
        ok ! is_Measure($v), "type of \"$v\" is-not-a " . Measure;
    }
};

done_testing;
