package WWW::Lyrics::Results;

use strict;
use WWW::Lyrics::Page;

use vars qw($VERSION);
$VERSION = '0.01';

sub new {
    my ($class, $top, $links) = @_;

    my $self = bless( {}, $class );
    $self->{_top} = $top;
    $self->{_links} = $links;

    return( $self );
}

sub fetch {
    my ($self) = @_;

    return( undef ) if ( @{ $self->{_links} } <= 0 );

    my $link = shift( @{ $self->{_links} } );
    my $res = $self->{_top}->{_ua}->get($link);

    return( WWW::Lyrics::Page->new( $link, $res ) );
}

sub count { scalar( @{ shift->{_links} } ) }

1;

__END__

=head1 NAME

WWW::Lyrics::Results - Internal module used by WWW::Lyrics

=head1 DESCRIPTION

This module is used internally by L<WWW::Lyrics> and therefore is not meant to
be handled directly.

=head1 AUTHOR

Nathan Bessette, C<E<lt>coruscate@cpan.orgE<gt>>

=head1 COPYRIGHT

Copyright (C) 2004 Nathan Bessette.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

=head1 SEE ALSO

L<WWW::Lyrics>, L<perl>

=cut