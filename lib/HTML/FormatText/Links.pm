# Copyright 2008 Kevin Ryde

# HTML-FormatExternal is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# HTML-FormatExternal is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with HTML-FormatExternal.  If not, see <http://www.gnu.org/licenses/>.

package HTML::FormatText::Links;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 11;

use constant { DEFAULT_LEFTMARGIN => 3,
               DEFAULT_RIGHTMARGIN => 77,
               _WIDE_CHARSET => 'iso-8859-1' };

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('links', '-version');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "Links 2.2"
  $version =~ /^Links (.*?) /i
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $option) = @_;

  if (defined $option->{'width'}) {
    $option->{'html-margin'} = 0;
  }
  if (my $input_charset = delete $option->{'input_charset'}) {
    # links (version 2.2 at least) accepts "latin1" but not "latin-1"
    # the latter is accepted by the other FormatExternal programs, so mung
    # it for convenience
    $input_charset =~ s/^(latin)-([0-9]+)$/$1$2/i;

    $option->{'html-assume-codepage'} = $input_charset;
    $option->{'html-hard-assume'} = 1;
  }
  if (my $output_charset = delete $option->{'output_charset'}) {
    $option->{'codepage'} = $output_charset;
  }

  return ('links',
          '-dump',
          '-force-html',

          # this secret crunching turns say
          #    'foo' => 123          into -foo 123
          #    'bar' => undef        into -bar
          #
          # there's probably a good chance of such pass-though only making a
          # mess, but the idea is to have some way to give arbitrary links
          # options
          #
          (map { defined $option->{$_} ? ("-$_", $option->{$_}) : ("-$_") }
           keys %$option));
}

1;
__END__

=head1 NAME

HTML::FormatText::Links - format HTML as plain text using links

=head1 SYNOPSIS

 use HTML::FormatText::Links;
 $text = HTML::FormatText::Links->format_file ($filename);
 $text = HTML::FormatText::Links->format_string ($html_string);

 $formatter = HTML::FormatText::Links->new (rightmargin => 60);
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Links> turns HTML into plain text using the C<links> program.

=over 4

L<http://links.twibright.com/>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by links.  See C<HTML::FormatExternal> for the
formatting functions and options, all of which are supported by
C<HTML::FormatText::Links>.

Note that though UTF-8 input can be given, the C<output_charset> cannot be
UTF-8.  Various unicode characters are turned into nice output though, for
instance smiley face U+263A becomes ":-)".

Links may be slightly picky about its charset names.  The module attempts to
ease that by for instance turning "latin-1" which not otherwise accepted
into "latin1" which is accepted.  (The full "ISO-8859-1" is accepted too.)

=head1 SEE ALSO

L<HTML::FormatExternal>

=head1 HOME PAGE

L<http://www.geocities.com/user42_kevin/html-formatexternal/index.html>

=head1 LICENSE

Copyright 2008 Kevin Ryde

HTML-FormatExternal is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

HTML-FormatExternal is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
HTML-FormatExternal.  If not, see L<http://www.gnu.org/licenses/>.

=cut
