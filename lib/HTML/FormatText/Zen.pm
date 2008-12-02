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

package HTML::FormatText::Zen;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 11;

use constant { DEFAULT_LEFTMARGIN => 3,
               DEFAULT_RIGHTMARGIN => 77 };

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('zen', '--version');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "zen version 0.2.3"
  $version =~ /^zen version (.*)/i
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $option) = @_;

  # is it worth enforcing/checking this ?
  #
  #   if (defined (my $input_charset = delete $option->{'input_charset'})) {
  #     $input_charset =~ /^latin-?1$|^iso-8859-1$/i
  #       or croak "Zen only accepts latin-1 input";
  #   }
  #   if (defined (my $output_charset = delete $option->{'output_charset'})) {
  #     $output_charset =~ /^latin-?1$|^iso-8859-1$/i
  #       or croak "Zen only produces latin-1 output";
  #   }

  delete $option->{'width'};

  return ('zen', '-i', 'dump');
}

1;
__END__

=head1 NAME

HTML::FormatText::Zen - format HTML as plain text using zen

=head1 SYNOPSIS

 use HTML::FormatText::Zen;
 $text = HTML::FormatText::Zen->format_file ($filename);
 $text = HTML::FormatText::Zen->format_string ($html_string);

 $formatter = HTML::FormatText::Zen->new;
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Zen> turns HTML into plain text using the C<zen>
program.

=over 4

L<http://www.nocrew.org/software/zen/>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by zen.

See C<HTML::FormatExternal> for the formatting functions.  But as of zen
version 0.2.3 none of the options are supported.  Input charset is always
latin-1, output is latin-1, dump width is 80 columns with no left margin.

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
