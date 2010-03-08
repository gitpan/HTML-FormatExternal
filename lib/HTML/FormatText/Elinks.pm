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

package HTML::FormatText::Elinks;
use 5.006;
use strict;
use warnings;
use HTML::FormatExternal;
our @ISA = ('HTML::FormatExternal');

our $VERSION = 17;

use constant DEFAULT_LEFTMARGIN => 3;
use constant DEFAULT_RIGHTMARGIN => 77;

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('elinks', '-version');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "ELinks 0.12pre2\n
  #      Built on Oct  2 2008 18:34:16"
  #
  $version =~ /^ELinks (.*)/i
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $options) = @_;
  my @command = ('elinks', '-dump', '-force-html');

  #   if ($options->{'ansi_colour'}) {
  #     push @command, '-eval', 'set document.dump.color_mode=1';
  #   }

  if (defined $options->{'_width'}) {
    push @command,
      '-dump-width', $options->{'_width'},
        '-eval', 'set document.browse.margin_width=0';
  }

  if (my $input_charset = $options->{'input_charset'}) {
    $input_charset = _elinks_mung_charset ($input_charset);
    push @command,
      '-eval', ('set document.codepage.assume='
                . _quote_config_stringarg ($input_charset)),
        '-eval', 'set document.codepage.force_assumed=1';

  }
  if (my $output_charset = $options->{'output_charset'}) {
    push @command, '-dump-charset', _elinks_mung_charset ($output_charset);
  }

  # 'elinks_options' not documented ...
  return (@command, @{$options->{'elinks_options'} || []});
}

# elinks (version 0.12pre2 at least) is picky about charset names in a
# similar fashion to the main "links" program (see Links.pm).  Turn
# "latin-1" into "latin1" here for convenience.
#
sub _elinks_mung_charset {
  my ($charset) = @_;
  $charset =~ s/^(latin)-([0-9]+)$/$1$2/i;
  return $charset;
}

# return $str with quotes around it, and backslashed within it, suitable for
# use in an elinks config file, or -eval of a config file line
sub _quote_config_stringarg {
  my ($str) = @_;
  $str =~ s/'/\\'/g;
  return "'$str'";
}

1;
__END__

=for stopwords elinks formatters Elinks pre multibyte charset utf charsets latin Ryde FormatExternal

=head1 NAME

HTML::FormatText::Elinks - format HTML as plain text using elinks

=for test_synopsis my ($text, $filename, $html_string, $formatter, $tree)

=head1 SYNOPSIS

 use HTML::FormatText::Elinks;
 $text = HTML::FormatText::Elinks->format_file ($filename);
 $text = HTML::FormatText::Elinks->format_string ($html_string);

 $formatter = HTML::FormatText::Elinks->new (rightmargin => 60);
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Elinks> turns HTML into plain text using the C<elinks>
program.

=over 4

http://elinks.cz/

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by elinks.

See C<HTML::FormatExternal> for the formatting functions and options, all of
which are supported by C<HTML::FormatText::Elinks> with the following
caveats.

=over 4

=item C<input_charset>

As of Elinks 0.12pre2 (Oct 2008) the only multibyte input charset accepted
is utf-8.  You can recode other charsets to utf-8 if necessary (this module
doesn't attempt to do that automatically).

=back

Elinks can be a little picky about its charset names.  This module attempts
to ease that by for instance turning "latin-1" (not accepted) into "latin1"
(which is accepted).  A full "ISO-8859-1" etc is accepted too.

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
