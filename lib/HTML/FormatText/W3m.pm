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

package HTML::FormatText::W3m;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 11;

use constant { DEFAULT_LEFTMARGIN => 0,
               DEFAULT_RIGHTMARGIN => 80 };

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('w3m', '-version');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "w3m version w3m/0.5.2, options lang=en,m17n,image,color,..."
  $version =~ m{^w3m version (?:w3m/)?(.*?),}i
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $option) = @_;

  # w3m seems to use one less than the given cols, presumably designed with
  # a tty in mind
  if (defined (my $width = delete $option->{'width'})) {
    $option->{'cols'} = $width + 1;
  }

  if (my $input_charset = delete $option->{'input_charset'}) {
    $option->{'I'} = $input_charset;
  }
  if (my $output_charset = delete $option->{'output_charset'}) {
    $option->{'O'} = $output_charset;
  }

  return ('w3m',
          '-dump',
          '-T', 'text/html',

          # this secret crunching turns say
          #    'o graphic_char' => 1 into -o graphic_char=1
          #    'foo' => 123          into -foo 123
          #    'bar' => undef        into -bar
          #
          # there's probably a good chance of such pass-though only making a
          # mess, but the idea is to have some way to give arbitrary w3m
          # options and config options
          #
          (map { $_ =~ /^o (.*)/s ? ('-o', "$1=".$option->{$_})
                   : defined $option->{$_} ? ("-$_", $option->{$_})
                     : "-$_"}
           keys %$option));
}

sub new {
  my ($class, %self) = @_;
  return bless \%self, $class;
}
sub format {
  my ($self, $html) = @_;
  if (ref $html) { $html = $html->as_HTML; }
  return $self->format_string ($html, %$self);
}

1;
__END__

=head1 NAME

HTML::FormatText::W3m - format HTML as plain text using w3m

=head1 SYNOPSIS

 use HTML::FormatText::W3m;
 $text = HTML::FormatText::W3m->format_file ($filename);
 $text = HTML::FormatText::W3m->format_string ($html_string);

 $formatter = HTML::FormatText::W3m->new (rightmargin => 60);
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::W3m> turns HTML into plain text using the C<w3m> program.

=over 4

L<http://sourceforge.net/projects/w3m>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by w3m.

See C<HTML::FormatExternal> for the formatting functions and options, all of
which are supported by C<HTML::FormatText::W3m>.

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
