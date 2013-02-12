use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Image::Layout;
use Try::Tiny;
use File::Basename;
use Class::Load qw/:all/;
use Encode;
use Image::Size qw/imgsize/;

my $dir = dirname(__FILE__);

subtest 'basic' => sub {
    subtest 'less parameters' => sub {
        try {
            new()->add_layout(
                type => 'Image',
            );
            fail 'should die';
        } catch {
            my $msg = shift;
            like $msg, qr/Missing parameter: 'file' \(or/;
            like $msg, qr/Missing parameter: 'url' \(or/;
            like $msg, qr/Missing parameter: 'width'/;
            like $msg, qr/Missing parameter: 'height'/;
        };

        try {
            new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                file   => "$dir/test.jpg",
                url    => 'http://localhost/test.jpg',
            );
            fail 'should die';
        } catch {
            my $msg = shift;
            like $msg, qr/Exclusive parameters passed together: 'file' v.s. 'url'/;
        };
    };
};

subtest 'image file' => sub {
    subtest 'jpg' => sub {
        try {
            my $l = new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                file   => "$dir/test.jpg",
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have errors';
        };
    };

    subtest 'png' => sub {
        try {
            my $l =new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                file   => "$dir/test.png",
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have errors';
        };
    };

    subtest 'multibypte included' => sub {
        try {
            my $l =new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                file   => "$dir/てすと.jpg",
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have errors';
        };
    };
};

subtest 'image url: http' => sub {
    subtest 'standard' => sub {
        try {
            my $l = new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                url    => 'http://upload.wikimedia.org/wikipedia/en/b/bd/Test.jpg',
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have error.';
        };
    };

    subtest 'multibyte included' => sub {
        try {
            my $l = new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                url    => 'http://upload.wikimedia.org/wikipedia/commons/a/af/テスト・ブランケット.JPG',
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have error.';
        };
    };
};

subtest 'image url: https' => sub {
    try_load_class('IO::Socket::SSL');

    if ( ! is_class_loaded('IO::Socket::SSL') ) {
        diag q{You don't have IO::Socket::SSL available, skip.};
        plan skip_all => q{You don't have IO::Socket::SSL available, skip.};
    }

    subtest 'standard' => sub {
        try {
            my $l = new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                url    => 'https://raw.github.com/issm/p5-Image-Layout/master/t/12_layout/04_image/test.jpg',
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have error.';
        };
    };

    subtest 'multibyte included' => sub {
        try {
            my $l = new()->add_layout(
                type   => 'Image',
                width  => 100,
                height => 100,
                url    => 'https://raw.github.com/issm/p5-Image-Layout/master/t/12_layout/04_image/てすと.jpg',
            )->_layouts->[0];
            isa_ok $l, 'Image::Layout::Image';
        } catch {
            warn shift;
            fail 'should not have error.';
        };
    };
};

subtest 'image size' => sub {
    for my $v ( 0 .. 4 ) {
        subtest "keep_aspect: $v" => sub {
            my %p = (
                type        => 'Image',
                file        => "$dir/test.jpg",
                keep_aspect => $v,
            );

            my $l;
            my ($w, $h);

            $l = new()->add_layout(
                %p,
                width  => 200,
                height => 50,
            )->_layouts->[0];

            ($w, $h) = imgsize( $l->file );
            is $l->width, $w;
            is $l->height, $h;

            $l = new()->add_layout(
                %p,
                width  => 50,
                height => 200,
            )->_layouts->[0];

            ($w, $h) = imgsize( $l->file );
            is $l->width, $w;
            is $l->height, $h;

            $l = new()->add_layout(
                %p,
                width  => 50,
                height => 50,
            )->_layouts->[0];

            ($w, $h) = imgsize( $l->file );
            is $l->width, $w;
            is $l->height, $h;
        };
    }
};

done_testing;
