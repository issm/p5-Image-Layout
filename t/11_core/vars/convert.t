use strict;
use warnings;
use Test::More;
use t::Util;
use Image::Layout;

my $image = Image::Layout->new();

sub f {
    my ($i) = @_;
    my @c = $i->compose();
    return $c[0];
}

like f($image), qr!^\s*/usr/bin/env convert\s.*!s;

{
    local $Image::Layout::CONVERT = '/home/foo/local/bin/convert';
    like f($image), qr!^\s*/home/foo/local/bin/convert\s.*!s;
}

like f($image), qr!^\s*/usr/bin/env convert\s.*!s;

done_testing;
