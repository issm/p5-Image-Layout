package Image::Layout::Text;
use strict;
use warnings;
use parent 'Image::Layout::Base';
use Image::Layout::Types qw/Unit Position Color/;
use MouseX::Types::Mouse qw/Str/;
use Class::Accessor::Lite (
    rw => [qw/font size color border_width border_color/],
);

sub extra_validation_rule {
    return (
        font         => { isa => Str, optional => 1 },
        size         => { isa => Unit, default => '1px' },
        color        => { isa => Color, default => '#000000' },
        border_width => { isa => Unit, default => 0 },
        border_color => { isa => Color, default => '#ffffff' },
    );
}

sub init {
    my ($self, %params) = @_;
    $self->font( $params{font} || $self->settings->font );
    $self->size( $self->to_px($params{size}) );
    $self->color( $params{color} );
    $self->border_width( $self->to_px($params{border_width}) );
    $self->border_color( $params{border_color} );
}

sub compose {
    my $self = shift;
    my @cmd;
    my $s = $self->settings;
    my ($x, $y) = @{$self->pos};
    my $text = $self->content;
    $text = ''  if ! defined $text;
    $text =~ s/"/\\"/g;

    if ( $self->border_width ) {
        push @cmd, << "        ...";
            -stroke '@{[$self->border_color]}'
            -strokewidth @{[$self->border_width]}
        ...
    }
    else {
        push @cmd, << "        ...";
            -stroke none
            -strokewidth 0
        ...
    }
    if ( defined $self->font ) {
        push @cmd, << "        ...";
            -font @{[$self->font]}
        ...
    }
    push @cmd, << "    ...";
        -pointsize @{[$self->size / $s->_pt2px_rate]}
        -fill '@{[$self->color]}'
        -encoding Unicode
        -draw 'text $x,$y \"$text\"'
    ...

    return @cmd;
}

1;
