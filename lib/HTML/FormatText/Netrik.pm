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

package HTML::FormatText::Netrik;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 13;

use constant { DEFAULT_LEFTMARGIN => 3,
               DEFAULT_RIGHTMARGIN => 77 };

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('netrik 2>&1');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  return (defined $version ? '' : undef);
}

sub _crunch_command {
  my ($class, $option) = @_;

  #   if (! $option->{'ansi_colour'}) {
  #     push @command, '--bw';
  #   }

  # COLUMNS influences the curses tigetnum("cols") used under --term-width.
  # Slightly hairy, but it has the right effect.
  if (defined $option->{'_width'}) {
    $option->{'ENV'}->{'COLUMNS'} = $option->{'_width'};
  }

  # 'netrik_options' not documented ...
  return ('netrik', '--dump', '--bw',
          @{$option->{'netrik_options'} || []});
}

1;
__END__

=head1 NAME

HTML::FormatText::Netrik - format HTML as plain text using netrik

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

L<http://netrik.sourceforge.net/>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by netrik.

See C<HTML::FormatExternal> for the formatting functions and options, except
the charset overrides have no effect.  Input might be single-byte only, and
output probably just follows the input (as of netrik 1.15.7).

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
