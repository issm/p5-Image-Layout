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

package MyLayout::PH1;
use parent 'Image::Layout::Base';
sub compose {
    return (
        qq{foo bar "\2aaa bbb\3" hoge},
        qq{"\2xxx yyy\3" fuga piyo},
    );
}

package MyLayout::PH2;
use parent 'Image::Layout::Base';
sub compose {
    return (
        qq{foo (bar baz) "\2aaa (bbb ccc) ddd\3"},
        qq{xxx (yyy zzz)},
    );
}

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


subtest 'basic' => sub {
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
};

subtest 'placeholding' => sub {
    subtest 'ph1' => sub {
        my ($image, $cmd) = ( new() );
        $image->add_layout( type => '+MyLayout::PH1' );
        $cmd = $image->_generate_cmd( 'out.jpg' );
        is $cmd, '/usr/bin/env convert foo bar "aaa bbb" hoge "xxx yyy" fuga piyo "out.jpg"';
    };

    subtest 'ph2' => sub {
        my ($image, $cmd) = ( new() );
        $image->add_layout( type => '+MyLayout::PH2' );
        $cmd = $image->_generate_cmd( 'out.jpg' );
        is $cmd, '/usr/bin/env convert foo \(bar baz\) "aaa (bbb ccc) ddd" xxx \(yyy zzz\) "out.jpg"';
    };

    subtest 'ph1 + ph2' => sub {
        my ($image, $cmd) = ( new() );
        $image->add_layout( type => '+MyLayout::PH1' );
        $image->add_layout( type => '+MyLayout::PH2' );
        $cmd = $image->_generate_cmd( 'out.jpg' );
        is $cmd, '/usr/bin/env convert foo bar "aaa bbb" hoge "xxx yyy" fuga piyo foo \(bar baz\) "aaa (bbb ccc) ddd" xxx \(yyy zzz\) "out.jpg"';
    };
};

done_testing;
