use strict;
use warnings;
use Test::More;
use t::Util;

my $if = new_layout_interface();

for my $case (
    { arg => [qw/left   top/],    expected => 'NorthWest' },
    { arg => [qw/left   middle/], expected => 'West' },
    { arg => [qw/left   bottom/], expected => 'SouthWest' },
    { arg => [qw/center top/],    expected => 'North' },
    { arg => [qw/center middle/], expected => 'Center' },
    { arg => [qw/center bottom/], expected => 'South' },
    { arg => [qw/right  top/],    expected => 'NorthEast' },
    { arg => [qw/right  middle/], expected => 'East' },
    { arg => [qw/right  bottom/], expected => 'SouthEast' },

    { arg => ['', ''],       expected => 'NorthWest' },
    { arg => [undef, undef], expected => 'NorthWest' },

    { arg => ['left',   ''], expected => 'NorthWest' },
    { arg => ['center', ''], expected => 'North' },
    { arg => ['right',  ''], expected => 'NorthEast' },
    { arg => ['', 'top'],    expected => 'NorthWest' },
    { arg => ['', 'middle'], expected => 'West' },
    { arg => ['', 'bottom'], expected => 'SouthWest' },

    { arg => ['foo', 'bar'], expected => 'NorthWest' },
) {
    my ($h, $v) = @{$case->{arg}};
    my $g = $case->{expected};
    $if->h_origin($h);
    $if->v_origin($v);

    my $h_ = defined $h ? qq{"$h"} : '(undef)';
    my $v_ = defined $v ? qq{"$v"} : '(undef)';
    is $if->_origin2gravity(), $g, "origin: $h_/$v_ -> gravity: $g";
}

done_testing;
