package Image::Layout::LayoutInterface;
use strict;
use warnings;
use Image::Layout::Util;
use Image::Layout::Types qw/
    Measure Unit Position
    is_Position
/;
use MouseX::Types::Mouse qw/Num Int Str ArrayRef HashRef Any/;
use Carp;
use Class::Load qw/try_load_class/;
use Class::Accessor::Lite (
    new => 0,
    rw => [qw/settings pos parent_pos
              h_origin v_origin
              _layouts/],
);

my %origin_map = (
    h => { left => 'West', center => 'Center', right => 'East' },
    v => { top => 'North', middle => 'Center', bottom => 'South' },
);

sub extra_validation_rule {
    return (
        h_origin => { isa => Str, default => 'left' },
        v_origin => { isa => Str, default => 'top' },
    );
}

sub to_px {
    my ($self, @args) = @_;
    my $v = validator(
        length => { isa => Unit|Position },
    )->with('StrictSequenced');
    my $p = $v->validate(@args);

    if ( is_Position( $p->{length} ) ) {
        return [ map $self->to_px($_), @{$p->{length}} ];
    }

    my ($val, $measure) = $p->{length} =~ qr/^\s* ([\+\-]? \d+(?:\.\d+)? ) \s* (\D+)? \s*$/x;
    return 0  if ! defined $val;
    $measure = $self->settings->measure  if ! defined $measure;
    $measure = lc $measure;

    my $ret = 0;

    if    ($measure eq 'mm')    { $ret = $self->_mm($val) }
    elsif ($measure eq 'cm')    { $ret = $self->_mm($val * 10) }
    elsif ($measure eq 'pt')    { $ret = $self->_pt($val) }
    elsif ($measure =~ /^\%w$/) { $ret = int($self->settings->width * $val / 100) }   # %w, %W
    elsif ($measure =~ /^\%h$/) { $ret = int($self->settings->height * $val / 100) }  # %h, %H
    else                        { $ret = int($val) }

    return $ret;
}

sub _mm {
    my ($self, @args) = @_;
    my $v = validator( mm => Num )->with('StrictSequenced');
    my $p = $v->validate(@args);
    return int( $p->{mm} * $self->settings->_mm2px_rate );
};

sub _pt {
    my ($self, @args) = @_;
    my $v = validator( pt => Num )->with('StrictSequenced');
    my $p = $v->validate(@args);
    return int( $p->{pt} * $self->settings->_pt2px_rate );
}

sub _origin2gravity {
    my $self = shift;
    my $ret = '';
    my ($h, $v) = (
        $origin_map{h}{ $self->h_origin || '' } || 'West',
        $origin_map{v}{ $self->v_origin || '' } || 'North',
    );
    $ret .= $v  if $v;
    $ret .= $h  if $h;
    $ret =~ s/(^Center|Center$)//;
    return $ret || 'none';
}

sub _create_layout {
    my ($self, %params) = @_;
    my $v = validator(
        type    => Str,
        pos     => { isa => Position, default => [0, 0] },
        rel_pos => { isa => Position, optional => 1 },
        content => { isa => Any, default => '' },
    )->with('AllowExtra');
    my ($p, %ex) = $v->validate(%params);

    my $layout_class;
    if ( $p->{type} =~ /^\+/ ) {
        ( $layout_class = $p->{type} ) =~ s/^\+//;
    }
    else {
      FOR_NAMESPACE:
        for my $ns ( 'Image::Layout', @Image::Layout::LAYOUT_NAMESPACES ) {
            if ( try_load_class( my $c = "$ns\::$p->{type}" ) ) {
                $layout_class = $c;
                last FOR_NAMESPACE;
            }
        }
    }

    my %params_layout = (
        settings   => $self->settings,
        pos        => $p->{pos},
        parent_pos => $self->pos,
        content    => $p->{content},
        %ex,
    );
    $params_layout{rel_pos} = $p->{rel_pos}  if exists $p->{rel_pos};

    return $layout_class->new(%params_layout);
}

sub add_layout {
    my ($self, %params) = @_;
    my $layout = $self->_create_layout(%params);
    push @{ $self->_layouts }, $layout;
    return $self;
}

sub compose { croak "[@{[ref($_[0])]}] override me!" }

sub dump {
    my $self = shift;
    my @cmds = $self->compose();
    #while ( my $l = shift @{$self->_layouts} ) {
    for my $l ( @{$self->_layouts} ) {
        push @cmds, $l->dump();
    }
    return @cmds;
}

1;
