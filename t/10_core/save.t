use strict;
use warnings;
use Test::More;
use t::Util;

my $image = new();

my $dir = tempdir( CLEANUP => 1 );
my $file;

$file = "$dir/foobar.jpg";
$image->save( file => $file );
ok -f $file;

$file = "$dir/foobar.png";
$image->save( file => $file );
ok -f $file;

done_testing;
