package WWW::Lyrics::Page;

use strict;
use URI;
use HTML::Parser;

use vars qw($VERSION);
$VERSION = '0.01';

sub new {
    my ($class, $url, $res) = @_;

    my $self = bless( {}, $class );
    $self->{_url} = $url;
    $self->{_source} = URI->new($url)->host();
    $self->{_code} = $res->code();

    my $html = $res->content();
    $html =~ s!<\s*br\s*/?\s*>\s*\n?!\n!ig;
    $html =~ s!</?i>!!g;
    $self->{_html} = $html;

    $self->{_parser} = HTML::Parser->new(
        handlers => {
            start_document => [ \&_parser_start, 'self' ],
            text           => [ \&_parser_text,  'self, dtext, is_cdata' ]
        },

        report_tags => []
    );

    return( $self );
}

sub _parser_start { shift->{_lyrics} = '' }

sub _parser_text {
    my ($self, $dtext, $is_cdata) = @_;

    unless ( $is_cdata ) {
        $dtext =~ s!\A\s+!!;
        $dtext =~ s!\s+\z!!;

        $self->{_lyrics} = $dtext if ( length($dtext) > length($self->{_lyrics}) );
    }
}

sub lyrics {
    my ($self) = @_;

    $self->{_parser}->parse( $self->{_html} );
    return( $self->{_parser}->{_lyrics} );
}

sub url { shift->{_url} }
sub source { shift->{_source} }
sub code { shift->{_code} }

1;

__END__

=head1 NAME

WWW::Lyrics::Page - Internal module used by WWW::Lyrics

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