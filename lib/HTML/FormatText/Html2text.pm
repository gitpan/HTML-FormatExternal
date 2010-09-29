# Copyright 2008, 2009, 2010 Kevin Ryde

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

package HTML::FormatText::Html2text;
use 5.006;
use strict;
use warnings;
use HTML::FormatExternal;
our @ISA = ('HTML::FormatExternal');

our $VERSION = 18;

use constant DEFAULT_LEFTMARGIN => 0;
use constant DEFAULT_RIGHTMARGIN => 79;
use constant _WIDE_CHARSET => 'iso-8859-1';

{
  my $help_done = 0;
  my $have_ascii;

  # return true if the "-ascii" option is available (new in html2text
  # version 1.3.2 from Jan 2004)
  sub _have_ascii {
    my ($class) = @_;
    $help_done ||= do {
      my $help = $class->_run_version ('html2text', '-help');
      $have_ascii = (defined $help && $help =~ /-ascii/);
      1;
    };
    return $have_ascii;
  }
}

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('html2text -version 2>&1');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "This is html2text, version 1.3.2a"
  $version =~ /^.*version (.*)/
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $options) = @_;
  my @command = ('html2text', '-nobs');

  if (defined $options->{'_width'}) {
    push @command, '-width', $options->{'_width'};
  }

  if ($class->_have_ascii) {
    if (my $output_charset = $options->{'output_charset'}) {
      $output_charset = lc($output_charset);
      if ($output_charset eq 'ascii' || $output_charset eq 'ansi_x3.4-1968') {
        push @command, '-ascii';
      }
    }
  }

  # 'html2text_options' not documented ...
  return (@command, @{$options->{'html2text_options'} || []});
}

1;
__END__

=for stopwords html formatters ascii charset latin Ryde FormatExternal

=head1 NAME

HTML::FormatText::Html2text - format HTML as plain text using html2text

=for test_synopsis my ($text, $filename, $html_string, $formatter, $tree)

=head1 SYNOPSIS

 use HTML::FormatText::Html2text;
 $text = HTML::FormatText::Html2text->format_file ($filename);
 $text = HTML::FormatText::Html2text->format_string ($html_string);

 $formatter = HTML::FormatText::Html2text->new;
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Html2text> turns HTML into plain text using the
C<html2text> program.

=over 4

http://www.mbayer.de/html2text/

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by html2text.

See C<HTML::FormatExternal> for the formatting functions and options, with
the following caveats,

=over 4

=item C<output_charset>

If set to "ascii" or "ANSI_X3.4-1968" (both case-insensitive) the C<-ascii>
option is used, when available (C<html2text> 1.3.2 from Jan 2004).  Apart
from that there's no control over the output charset.

=item C<input_charset>

Currently this option has no effect, input generally has to be latin-1 only
(but with some further characters accepted as C<&> style named entities).

=back

=head1 SEE ALSO

L<HTML::FormatExternal>

=head1 HOME PAGE

http://user42.tuxfamily.org/html-formatexternal/index.html

=head1 LICENSE

Copyright 2008, 2009, 2010 Kevin Ryde

HTML-FormatExternal is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

HTML-FormatExternal is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
HTML-FormatExternal.  If not, see <http://www.gnu.org/licenses/>.

=cut
