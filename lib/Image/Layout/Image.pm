package Image::Layout::Image;
use strict;
use warnings;
use utf8;
use parent 'Image::Layout::Base';
use Image::Layout::Types qw/Unit Position Color/;
use MouseX::Types::Mouse qw/Bool Int Num Str/;
use File::Copy ();
use File::Temp ();
use Image::Size ();
use Encode;
use Class::Load qw/:all/;
use Class::Accessor::Lite (
    rw => [qw/file width height keep_aspect rotate bgcolor
              _tmpfiles
             /],
);

sub DESTROY {
    my $self = shift;
    while ( my $f = shift @{ $self->_tmpfiles } ) {
        unlink $f if -f $f;
    }
}

sub extra_validation_rule {
    my $self = shift;
    return (
        file         => { isa => Str, xor => 'url' },
        url          => { isa => Str, xor => 'file' },
        width        => { isa => Unit },
        height       => { isa => Unit },
        keep_aspect  => { isa => Int, default => 3 },
        rotate       => { isa => Num, default => 0 },
        bgcolor      => { isa => Color, default => '#00000000' },
        $self->SUPER::extra_validation_rule(),
    );
    # parameter "keep_aspect"
    #   1: based on width
    #   2: based on height
    #   3: based on longer
    #   4: based on shorter
}

sub init {
    my ($self, %params) = @_;
    $self->width( $self->to_px($params{width}) );
    $self->height( $self->to_px($params{height}) );
    $self->keep_aspect( $params{keep_aspect} );
    $self->rotate( $params{rotate} );
    $self->bgcolor( $params{bgcolor} );
    $self->h_origin( $params{h_origin} );
    $self->v_origin( $params{v_origin} );
    $self->_tmpfiles( [] );

    my $file;
    if ( defined $params{url} ) {
        (my $fh_tmp, $file) = File::Temp::tempfile( UNLINK => 0 );  # remove on DESTROY

        load_class('Furl');
        try_load_class('IO::Socket::SSL');

        my %params_ua = (
            agent   => "Image::Layout/$Image::Layout::VERSION",
            timeout => 10,
        );
        if ( is_class_loaded('IO::Socket::SSL') ) {
            $params_ua{ssl_opts} = {
                SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_PEER(),
            },
        }
        else {
            warn 'IO::Socket::SSL is not available.';
        }
        my $ua = Furl->new(%params_ua);
        my $url = encode_utf8( $params{url} );
        my $res = $ua->get($url);
        if ( $res->code != 200 ) {
            die 'filed to fetch image: ' . $res->status_line;
        }
        $fh_tmp->print( $res->content );
        close $fh_tmp;
        push @{$self->_tmpfiles}, $file;
    }
    else {
        $file = $params{file};
        #File::Copy::copy $params{file}, $tmpfile;
    }

    my (undef, $tmpfile) = File::Temp::tempfile( UNLINK => 0 );  ## remove on DESTROY
    {
        my ($w, $h) = ($self->width, $self->height);
        my $resize_geom = '';

        if ( my $ka = $self->keep_aspect ) {
            my ($w0, $h0, $ext) = map lc, Image::Size::imgsize($file);
            my $base;
            if    ( $ka == 1 ) { $base = 'w' }
            elsif ( $ka == 2 ) { $base = 'h' }
            elsif ( $ka == 3 ) { $base = $w0 >= $h0 ? 'w' : 'h' }
            elsif ( $ka == 4 ) { $base = $w0 <= $h0 ? 'w' : 'h' }
            else               { $base = 'w' }
            $resize_geom = $base eq 'w' ? "${w}x" : "x${h}";
        }
        else {
            $resize_geom = "${w}x${h}!";
        }


        my $cmd = encode_utf8( << "        ..." );
            $Image::Layout::CONVERT $file -quality 100 -resize $resize_geom $tmpfile
        ...
            $cmd =~ s/[\n\s]+/ /g;
        #warn "[33m$cmd[0m";
        my $code = system($cmd);

        push @{$self->_tmpfiles}, $tmpfile;

        ($w, $h) = Image::Size::imgsize($tmpfile);
        $self->width($w);
        $self->height($h);
    }

    $self->file( $tmpfile );
}

sub compose {
    my $self = shift;
    my @cmd;
    my $s = $self->settings;
    my ($x, $y) = @{$self->pos};
    my ($w, $h) = ($self->width, $self->height);
    my $r = $self->rotate;
    my $bgcolor = $self->bgcolor;
    my $file = $self->file;
    my $gravity = $self->_origin2gravity();

    push @cmd, << "    ...";
        (
            $file
            -geometry +${x}+${y}
            -gravity $gravity
            -background '${bgcolor}'
            -rotate $r
        )
        -composite
    ...

    return @cmd;
}

1;
