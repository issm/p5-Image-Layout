package Image::Layout;
use 5.008;
use strict;
use warnings;
use utf8;
use parent 'Image::Layout::LayoutInterface';
use Image::Layout::Util;
use Image::Layout::Settings;
use Image::Layout::Types qw/Measure Unit Color/;
use MouseX::Types::Mouse qw/Undef Bool Int Num Str ArrayRef HashRef Any/;
use Try::Tiny;
use Encode;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw//],
);

our $VERSION = '0.00_01';
our $CONVERT = '/usr/bin/env convert';
our $SSL_VERIFY_NONE = 0;
our @LAYOUT_NAMESPACES;

sub new {
    my ($class, %params) = @_;
    my $v = validator(
        dpi     => { isa => Int, default => 72 },
        measure => { isa => Measure, default => 'px' },
        width   => { isa => Int, default => 0 },
        height  => { isa => Int, default => 0 },
        bgcolor => { isa => Color, optional => 1 },
        quality => { isa => Int, default => 90 },
        font    => { isa => Str, optional => 1 },
    );
    my $p = $v->validate(\%params);
    my $self = bless {}, $class;
    return $self->_init(%$p);
}

sub _init {
    my ($self, %params) = @_;

    my $settings = Image::Layout::Settings->new(
        dpi     => $params{dpi},
        measure => $params{measure},
        width   => $params{width},
        height  => $params{height},
        bgcolor => $params{bgcolor},
        quality => $params{quality},
        font    => $params{font},
    );
    $self->settings($settings);
    $settings->width( $self->to_px( $params{width} ) );
    $settings->height( $self->to_px( $params{height} ) );

    $self->_layouts( [] );
    $self->pos( [0, 0] );
    $self->parent_pos( [0, 0] );
    return $self;
}

sub _generate_cmd {
    my ($self, $file) = @_;
    my @cmds = $self->dump();
    push @cmds, qq{"$file"};
    ( my $cmd = join "\n", @cmds ) =~ s/(^\s*|\s*$)//g;;
    $cmd =~ s/[\n\s]+/ /g;
    $cmd =~ s/([\(\)])/\\$1/g;  # escape '(' and ')'
    return $cmd;
}

sub add_layout_namespace {
    my ($self, @args) = @_;
    push @LAYOUT_NAMESPACES, @args;
    return $self;
}

sub compose {
    my $self = shift;
    my $s = $self->settings;
    my @cmd;
    push @cmd, << "    ...";
        $CONVERT
            -colorspace RGB
            -quality @{[$s->quality]}
            -density @{[$s->dpi]}x@{[$s->dpi]}
            -size @{[$s->width]}x@{[$s->height]}
            canvas:@{[ $s->bgcolor || 'none' ]}
    ...
    return @cmd;
}

sub save {
    my ($self, %params) = @_;
    my $v = validator(
        file     => { isa => Str },
        show_cmd => { isa => Int, default => 0 },
    );
    my $p = $v->validate(\%params);

    my $cmd = encode_utf8( $self->_generate_cmd($p->{file}) );
    if ( my $col = $p->{show_cmd} ) {
        warn "[${col}m$cmd[0m";
    }
    my $code = system($cmd);

    # use Data::Dumper; warn Dumper \@cmds;
}


1;
__END__

=head1 NAME

Image::Layout - The great new Image::Layout!


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Image::Layout;

    my $foo = Image::Layout->new();
    ...


=head1 METHODS

=head2 new

...


=head1 AUTHOR

IWATA, Susumu, C<< <issmxx at gmail.com> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-image-layout at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Image-Layout>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Image::Layout


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Image-Layout>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Image-Layout>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Image-Layout>

=item * Search CPAN

L<http://search.cpan.org/dist/Image-Layout/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 IWATA, Susumu.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut
