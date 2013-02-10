package Image::Layout::Settings;
use strict;
use warnings;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/
        dpi
        measure
        width
        height
        bgcolor
        quality
        font
        width_orig
        height_orig
        _mm2px_rate
        _pt2px_rate
    /],

);

sub new {
    my ($class, %params) = @_;
    my $self = bless +{}, $class;

    $self->dpi( $params{dpi} );
    $self->measure( $params{measure} );
    $self->bgcolor( $params{bgcolor} );
    $self->quality( $params{quality} );
    $self->font( $params{font} );
    $self->font( $params{font} );
    $self->width_orig( $params{width} );
    $self->height_orig( $params{height} );

    my $dpi = $self->dpi;
    $self->_mm2px_rate( $dpi / 25.4 );
    $self->_pt2px_rate( $dpi / 72 );
    return $self;
}

1;
