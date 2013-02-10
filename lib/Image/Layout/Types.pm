package Image::Layout::Types;
use strict;
use warnings;
use utf8;
use MouseX::Types -declare => [qw/
    Measure
    Unit
    Position
    Color
/];
use MouseX::Types::Mouse map { ($_, "is_$_") } qw/Str Int Num ArrayRef/;
use Test::Deep;

sub is { code( \&{"is_@{[ (split /::/, $_[0])[-1] ]}"} ) }


subtype Measure,
    as Str,
    where { /^(px|mm|cm|pt)$/ } ;

subtype Unit,
    as Str,
    where { /^[+-]?\d+(\.\d+)?(px|mm|cm|pt|\%[wW]|\%[hH])?$/ } ;

subtype Position,
    as ArrayRef,
    where {
        eq_deeply( $_, [is(Unit), is(Unit)] );
    } ;

subtype Color,
    as Str,
    where { /^#[0-9a-f]{6}$/i } ;

1;
