package Image::Layout::Base;
use strict;
use warnings;
use parent 'Image::Layout::LayoutInterface';
use Image::Layout::Util;
use Image::Layout::Types qw/Position/;
use MouseX::Types::Mouse qw/Undef Any/;
use Class::Accessor::Lite (
    new => 0,
    rw => [qw/content/],
);

sub new {
    my ($class, %params) = @_;
    my $v = validator(
        settings   => { isa => 'Image::Layout::Settings' },
        pos        => { isa => Position, default => [0, 0] },
        rel_pos    => { isa => Position, optional => 1 },
        parent_pos => { isa => Position, default => [0, 0] },
        content    => { isa => Any, default => Undef },
        ($class->extra_validation_rule),
    );
    my $p = $v->validate(\%params);

    my $self = bless {}, $class;
    $self->_init(%$p);
    $self->init(%$p);
    return $self;
}

sub _init {
    my ($self, %params) = @_;
    $self->_layouts( [] );
    $self->settings( $params{settings} );
    $self->parent_pos( $params{parent_pos} );  # 必ず px 単位であるべき
    if ( exists $params{rel_pos} ) {
        my @rel_pos = @{ $self->to_px( $params{rel_pos} ) };
        my @par_pos = @{$self->parent_pos};

        $self->pos( [
            (shift @par_pos) + (shift @rel_pos),
            (shift @par_pos) + (shift @rel_pos),
        ] );
    }
    else {
        $self->pos( $self->to_px( $params{pos} ) );
    }
    $self->content( $params{content} );
}

sub init { shift }

1;
