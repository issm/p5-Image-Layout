package Image::Layout;
use 5.008;
use strict;
use warnings;

our $VERSION = '0.00_01';

sub new {
    my ($class, %params) = @_;
    my $self = bless {}, $class;
    return $self;
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
