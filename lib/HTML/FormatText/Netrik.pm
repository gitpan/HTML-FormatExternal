# Copyright 2008, 2009, 2010, 2013 Kevin Ryde

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

package HTML::FormatText::Netrik;
use 5.006;
use strict;
use warnings;
use URI::file;
use HTML::FormatExternal;
our @ISA = ('HTML::FormatExternal');

# uncomment this to run the ### lines
# use Smart::Comments;

our $VERSION = 20;

use constant DEFAULT_LEFTMARGIN => 3;
use constant DEFAULT_RIGHTMARGIN => 77;

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version (['netrik'], '2>&1');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # as of netrik 1.15.7 there doesn't seem to be any option that prints the
  # version number, it's possible it's not compiled into the binary at all
  return '(not reported)';
}

sub _make_run {
  my ($class, $input_filename, $options) = @_;

  #   if (! $options->{'ansi_colour'}) {
  #     push @command, '--bw';
  #   }

  # COLUMNS influences the curses tigetnum("cols") used under --term-width.
  # Slightly hairy, but it has the right effect.
  if (defined $options->{'_width'}) {
    $options->{'ENV'}->{'COLUMNS'} = $options->{'_width'};
  }

  # 'netrik_options' not documented ...
  return ([ 'netrik', '--dump', '--bw',
            @{$options->{'netrik_options'} || []},

            # netrik interprets "%" in the input filename as URI style %ff hex
            # encodings.  And it rejects filenames with non-URI chars such as
            # "-" (except for "-" alone which means stdin).  Turn unusual
            # filenames like "%" or "-" into full file:// using URI::file.
            URI::file->new_abs($input_filename)->as_string,
          ]);
}

1;
__END__

=for stopwords HTML-FormatExternal netrik sourceforge.net formatters charset Ryde

=head1 NAME

HTML::FormatText::Netrik - format HTML as plain text using netrik

=for test_synopsis my ($text, $filename, $html_string, $formatter, $tree)

=head1 SYNOPSIS

 use HTML::FormatText::Netrik;
 $text = HTML::FormatText::Netrik->format_file ($filename);
 $text = HTML::FormatText::Netrik->format_string ($html_string);

 $formatter = HTML::FormatText::Netrik->new;
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Netrik> turns HTML into plain text using the C<netrik>
program.

=over 4

http://netrik.sourceforge.net/

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by netrik.

See C<HTML::FormatExternal> for the formatting functions and options, with
the following caveats,

=over 4

=item C<input_charset>, C<output_charset>

These charset overrides have no effect.  Input might be single-byte only,
and output probably follows the input (as of netrik 1.15.7).

=back

=head1 SEE ALSO

L<HTML::FormatExternal>, L<netrik(1)>

=head1 HOME PAGE

http://user42.tuxfamily.org/html-formatexternal/index.html

=head1 LICENSE

Copyright 2008, 2009, 2010, 2013 Kevin Ryde

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
