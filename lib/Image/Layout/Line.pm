package Image::Layout::Line;
use strict;
use warnings;
use parent 'Image::Layout::Base';
use Image::Layout::Types qw/Unit Position Color/;
use Class::Accessor::Lite (
    rw => [qw/to size color/],
);

sub extra_validation_rule {
    return (
        to     => { isa => Position, optional => 1, xor => 'rel_to' },
        rel_to => { isa => Position, optional => 1, xor => 'to' },
        size   => { isa => Unit, default => '1px' },
        color  => { isa => Color, default => '#000000' },
    );
}

sub init {
    my ($self, %params) = @_;
    if ( exists $params{rel_to} ) {
        my @pos    = @{$self->pos};
        my @rel_to = @{ $self->to_px($params{rel_to}) };
        $self->to( [
            (shift @pos) + (shift @rel_to),
            (shift @pos) + (shift @rel_to),
        ] );
    }
    else {
        $self->to( $self->to_px($params{to}) );
    }
    $self->size( $self->to_px($params{size}) );
    $self->color( $params{color} );
}

sub compose {
    my $self = shift;
    my $s = $self->settings;
    my ($x0, $y0) = @{$self->pos};
    my ($x1, $y1) = @{$self->to};
    my $size = $self->size;

    my $cmd = << "    ...";
        -stroke '@{[$self->color]}'
        -strokewidth '@{[$self->size]}'
        -gravity none
        -draw 'line $x0,$y0 $x1,$y1'
    ...

    return ($cmd);
}

1;
