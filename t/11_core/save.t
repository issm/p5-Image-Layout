use strict;
use warnings;
use Test::More;
use t::Util;

my $image = new();

my $dir = tempdir( CLEANUP => 1 );
my $file;

subtest 'jpg' => sub {
    $file = "$dir/foobar.jpg";
    $image->save( file => $file );
    ok -f $file;
};

subtest 'png' => sub {
    $file = "$dir/foobar.png";
    $image->save( file => $file );
    ok -f $file;
};

subtest 'includes "spaces"' => sub {
    $file = "$dir/foo bar baz.jpg";
    $image->save( file => $file );
    ok -f $file;
};

done_testing;
