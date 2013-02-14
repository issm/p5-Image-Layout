package MyLayout1;
use parent 'Image::Layout::Base';
sub compose {
    return ( << "    ..." );
        foo
        bar
    ...
}
1;

package MyLayout2;
use parent 'Image::Layout::Base';
sub compose {
    return ( << "    ..." );
        ( foo bar
          baz
        )
    ...
}
1;

package Image::Layout;
{
    no strict 'refs';
    *{__PACKAGE__ . '::compose'} = sub {
        return ( '/usr/bin/env convert' );
    };
}
1;

package main;
use strict;
use warnings;
use Test::More;
use t::Util;

my $image = new();
my $cmd;

$cmd = $image->_generate_cmd('out.jpg');
is $cmd, '/usr/bin/env convert "out.jpg"';

$image->add_layout(
    type => '+MyLayout1',
);
$cmd = $image->_generate_cmd('out.jpg');
is $cmd, '/usr/bin/env convert foo bar "out.jpg"';

$image->add_layout(
    type => '+MyLayout2',
);
$cmd = $image->_generate_cmd('out.jpg');
is $cmd, '/usr/bin/env convert foo bar \( foo bar baz \) "out.jpg"';

$cmd = $image->_generate_cmd('foo bar baz.jpg');
is $cmd, '/usr/bin/env convert foo bar \( foo bar baz \) "foo bar baz.jpg"';

done_testing;
