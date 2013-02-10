package Image::Layout::Rect;
use strict;
use warnings;
use parent 'Image::Layout::Base';
use Image::Layout::Types qw/Unit Color/;
use Class::Accessor::Lite (
    rw => [qw/width height bgcolor border_width border_color/],
);

sub extra_validation_rule {
    return (
        bgcolor      => { isa => Color, default => '#ffffff' },
        width        => Unit,
        height       => Unit,
        border_width => { isa => Unit, default => 0 },
        border_color => { isa => Color, default => '#ffffff' },
    );
}

sub init {
    my ($self, %params) = @_;
    $self->width( $self->to_px($params{width}) );
    $self->height( $self->to_px($params{height}) );
    $self->bgcolor( $params{bgcolor} );
    $self->border_width( $self->to_px($params{border_width}) );
    $self->border_color( $params{border_color} );

    if ( $self->border_width ) {
        my ($x, $y) = @{$self->pos};
        my ($w, $h) = ($self->width, $self->height);

        for my $i (
            { pos => [ "${x}px", "${y}px" ], rel_to => [ "${w}px", 0 ] },
            { pos => [ "${x}px", "${y}px" ], rel_to => [ 0, "${h}px" ] },
            { pos => [ "@{[$x + $w]}px", "@{[$y + $h]}px" ], rel_to => [ "-${w}px", 0 ] },
            { pos => [ "@{[$x + $w]}px", "@{[$y + $h]}px" ], rel_to => [ 0, "-${h}px" ] },
        ) {
            $self->add_layout(
                type => 'Line',
                %$i,
                size  => $self->border_width . 'px',
                color => $self->border_color,
            );
        }
    }
}

sub compose {
    my $self = shift;
    my @cmd;

    my ($x, $y) = @{$self->pos};
    my ($w, $h) = ($self->width, $self->height);

    push @cmd, << "    ...";
        -fill '@{[$self->bgcolor]}'
        -draw 'rectangle $x,$y @{[$x + $w]},@{[$y + $h]}'
    ...

    return @cmd;
}

1;
