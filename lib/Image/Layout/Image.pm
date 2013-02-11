package Image::Layout::Image;
use strict;
use warnings;
use utf8;
use parent 'Image::Layout::Base';
use Image::Layout::Types qw/Unit Position Color/;
use MouseX::Types::Mouse qw/Bool Int Str/;
use File::Copy ();
use File::Temp ();
use Image::Size ();
use Encode;
use Class::Load qw/:all/;
use Class::Accessor::Lite (
    rw => [qw/file width height keep_aspect h_origin v_origin
              _tmpfiles
             /],
);

my %origin_map_h = ( left => 'West', center => 'Center', right => 'East' );
my %origin_map_v = ( top => 'North', middle => 'Center', bottom => 'South' );

sub DESTROY {
    my $self = shift;
    while ( my $f = shift @{ $self->_tmpfiles } ) {
        unlink $f if -f $f;
    }
}

sub extra_validation_rule {
    return (
        file         => { isa => Str, optional => 1, xor => 'url' },
        url          => { isa => Str, optional => 1, xor => 'file' },
        width        => { isa => Unit },
        height       => { isa => Unit },
        keep_aspect  => { isa => Int, default => 3 },
        h_origin     => { isa => Str, default => 'left' },
        v_origin     => { isa => Str, default => 'top' },
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
    $self->h_origin( $origin_map_h{ $params{h_origin} } || 'West' );
    $self->v_origin( $origin_map_v{ $params{v_origin} } || 'North' );
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
        my $res = $ua->get( $params{url} );
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
            $Image::Layout::CONVERT $file -resize $resize_geom $tmpfile
        ...
        #warn "[33m$cmd[0m";
        my $code = system($cmd);

        push @{$self->_tmpfiles}, $tmpfile;
    }

    $self->file( $tmpfile );
}

sub compose {
    my $self = shift;
    my @cmd;
    my $s = $self->settings;
    my ($x, $y) = @{$self->pos};
    my ($w, $h) = ($self->width, $self->height);
    my $file = $self->file;
    ( my $origin = $self->v_origin . $self->h_origin ) =~ s/(^Center|Center$)//;


#        -geometry ${w}x${h}+${x}+${y}
    push @cmd, << "    ...";
        $file
        -geometry +${x}+${y}
        -gravity $origin
        -composite
    ...

    return @cmd;
}

1;
