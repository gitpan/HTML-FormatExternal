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

package HTML::FormatText::Elinks;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 11;

use constant { DEFAULT_LEFTMARGIN => 3,
               DEFAULT_RIGHTMARGIN => 77 };

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
  my ($class, $option) = @_;

  #   if (delete $option->{'ansi_colour'}) {
  #     $option->{'document.dump.color_mode'} = 1;
  #   }

  if (defined (my $width = delete $option->{'width'})) {
    $option->{'dump-width'} = $width;
    $option->{'document.browse.margin_width'} = 0;
  }

  if (my $input_charset = delete $option->{'input_charset'}) {
    $option->{'document.codepage.assume'} = "'$input_charset'";
    $option->{'document.codepage.force_assumed'} = 1;

  }
  if (my $output_charset = delete $option->{'output_charset'}) {
    $option->{'dump-charset'} = $output_charset;
  }

  return ('elinks',
          '-dump',
          '-force-html',

          # this secret crunching turns say
          #    'foo' => 123          into -foo 123
          #    'bar' => undef        into -bar
          #    'document.html.wrap_nbsp' => 1
          #       into -eval set document.html.wrap_nbsp=1
          #
          # there's probably a good chance of such pass-though only making a
          # mess, but the idea is to have some way to give arbitrary elinks
          # options
          #
          (map { $_ =~ /\./ ? ('-eval', "set $_=".$option->{$_})
                   : defined $option->{$_} ? ("-$_", $option->{$_})
                     : ("-$_") }
           keys %$option));
}

1;
__END__

=head1 NAME

HTML::FormatText::Elinks - format HTML as plain text using elinks

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

L<http://elinks.cz/>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by elinks.

See C<HTML::FormatExternal> for the formatting functions and options, all of
which are supported by C<HTML::FormatText::Elinks>.

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
