package WWW::Lyrics;

use strict;
use URI;
use URI::Escape;
use HTML::Parser;
use LWP::UserAgent;
use WWW::Lyrics::Results;

use vars qw($VERSION);
$VERSION = '0.01';

my @_sites = qw(
    sing365.com     musicsonglyrics.com
    123lyrics.net   lyricsdepot.com
    azlyrics.com    lyricsfreak.com
    elyrics.net
);

sub new {
    my ($class, $terms) = @_;
    $terms ||= '';

    my $self = bless( {}, $class );

    $self->{_ua} = LWP::UserAgent->new(
        timeout => 10,
        agent   => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1) ' .
                   'Opera 7.23 [en]'
    );

    $self->{_parser} = HTML::Parser->new(
        handlers => {
            start_document => [ \&_parser_start,    'self' ],
            start          => [ \&_parser_starttag, 'self, tagname, attr' ]
        },

        report_tags => [ qw( a ) ]
    );

    my $res = $self->{_ua}->get(
        'http://www.google.com/search?q=lyrics%20' .
         uri_escape( $terms ) . '&num=50' .
        '&ie=UTF-8&oe=UTF-8&hl=en&btnG=Google%20Search',

        Referer => 'http://www.google.com/'
    );

    $res->is_success() or die(
        "Unable to retrieve search results: ${\$res->status_line()}\n"
    );

    $self->{_parser}->parse( $res->content() );
    my @links = grep {
        my $link = $_;
        grep { $link =~ m!\Ahttp://(?:www\.)?$_!i } @_sites
    } map {
        URI->new_abs( $_, 'http://www.google.com' )->as_string()
    } @{ $self->{_parser}->{_links} };

    return( WWW::Lyrics::Results->new( $self, \@links ) );
}

sub _parser_start {
    my ($self) = @_;

    $self->{_links} = [];
}

sub _parser_starttag {
    my ($self, $tag, $attr) = @_;

    push( @{ $self->{_links} }, $attr->{href} )
        if ( ($tag eq 'a') and ( exists($attr->{href}) ) );
}

1;

__END__

=head1 NAME

WWW::Lyrics - Fetch song lyrics from the internet

=head1 SYNOPSIS

  use WWW::Lyrics;

  my $terms = join(' ', @ARGV) || '';
  my $lyr = WWW::Lyrics->new( $terms );

  print "We found ", $lyr->count(), " results matching our search!\n\n";

  while ( my $page = $lyr->fetch() ) {
      if ( $page->code() != 200 ) {
          warn "Fetch failed (HTTP status code ", $page->code(), ")\n";
          next;
      }

      print "Got lyrics from ", $page->source(), "!\n\n";
      print "Exact URL: ", $page->url(), "\n\n";
      print "THE LYRICS:\n\n", $page->lyrics(), "\n\n";

      sleep 3;
  }

  print "No more results found!\n";

=head1 DESCRIPTION

This module allows you to easily retrieve lyrics for most songs you can throw
at it.  You simply provide the artist name and/or song title and the module does
the rest of the work for you.  The lyrics are retrieved from multiple lyrics
servers just in case the first result does not provide the content you are
looking for.

=head1 INTERFACE

The interface provided by WWW::Lyrics is concise and simple. There are few
methods available, so keeping things neat is extremely easy. Here's how to begin:

First, we create a new WWW::Lyrics object for a brand new search:

  # let's search for some lyrics
  my $lyr = WWW::Lyrics->new( $terms );

Now that we have setup and executed a new search, we have two methods we can now
access through C<$lyr>. The first tells us how many search results were found:

  print "We found ", $lyr->count(), " results matching our search!\n";

The second method is C<fetch()>, which returns the next search result in a new
object. If no more search results are available, the method returns undef. This
is a good place to use a C<while()> loop:

  while ( my $page = $lyr->fetch() ) {
      # $page holds our next search result

Each lyric object we fetch has 4 methods of its own. The first is C<code()>,
which provides the HTTP status code returned by the page we tried to fetch. If
this value is not 200, then we cannot retrieve lyrics for that result.

  if ( $page->code() != 200 ) {
      warn "Fetch failed (HTTP status code ", $page->code(), ")\n";
      next;
  }

The next 2 methods available are C<source()> and C<url()>. C<source()> gives us
the domain on which we found the lyrics we have retrieved. C<url()> gives the
exact URL where the lyrics were found.

  print "Got lyrics from ", $page->source(), "!\n\n";
  print "Exact URL: ", $page->url(), "\n\n";

The final method available to us is the body of text that is the lyrics. We
grab the actual lyrics by calling C<lyrics()>:

  print "THE LYRICS:\n\n", $page->lyrics(), "\n\n";

That's all there is to it! Our final entire program looks like this:

  use WWW::Lyrics;

  my $terms = join(' ', @ARGV) || '';
  my $lyr = WWW::Lyrics->new( $terms );

  print "We found ", $lyr->count(), " results matching our search!\n\n";

  while ( my $page = $lyr->fetch() ) {
      if ( $page->code() != 200 ) {
          warn "Fetch failed (HTTP status code ", $page->code(), ")\n";
          next;
      }

      print "Got lyrics from ", $page->source(), "!\n\n";
      print "Exact URL: ", $page->url(), "\n\n";
      print "THE LYRICS:\n\n", $page->lyrics(), "\n\n";

      sleep 3;
  }

  print "No more results found!\n";

=head1 PREREQUISITES

All modules on which WWW::Lyrics is dependent are part of the core perl
distribution.  WWW::Lyrics limits itself to the use of L<URI>, L<URI::Escape>,
L<HTML::Parser>, and L<LWP::UserAgent>.

=head1 AUTHOR

Nathan Bessette, C<E<lt>coruscate@cpan.orgE<gt>>

=head1 COPYRIGHT

Copyright (C) 2004 Nathan Bessette.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

=head1 SEE ALSO

L<perl>

=cut