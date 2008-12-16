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

package HTML::FormatText::Lynx;
use strict;
use warnings;
use Carp;
use base 'HTML::FormatExternal';

our $VERSION = 13;

use constant { DEFAULT_LEFTMARGIN => 2,
               DEFAULT_RIGHTMARGIN => 72 };

my $help_done = 0;
my $have_nomargins;
sub _have_nomargins {
  $help_done ||= do {
    my $help = __PACKAGE__->_run_version ('lynx', '-help');
    $have_nomargins = ($help =~ /-nomargins/);
    1;
  };
  return $have_nomargins;
}

sub program_full_version {
  my ($self_or_class) = @_;
  return $self_or_class->_run_version ('lynx', '-version');
}
sub program_version {
  my ($self_or_class) = @_;
  my $version = $self_or_class->program_full_version;
  if (! defined $version) { return undef; }

  # eg. "Lynx Version 2.8.7dev.10 (21 Sep 2008)"
  $version =~ /^Lynx Version (.*?) \(/i
    or $version =~ /^(.*)/;  # whole first line if format not recognised
  return $1;
}

sub _crunch_command {
  my ($class, $option) = @_;
  my @command = ('lynx', '-dump', '-force_html');

  if (defined $option->{'_width'}) {
    push @command, '-width', $option->{'_width'};
    if (_have_nomargins()) {
      push @command, '-nomargins';
    }
  }
  if (my $input_charset = $option->{'input_charset'}) {
    push @command, '-assume_charset', $input_charset;
  }
  if (my $output_charset = $option->{'output_charset'}) {
    push @command, '-display_charset', $output_charset;
  }

  # not documented ... yet
  if ($option->{'justify'}) {
    push @command, '-justify';
  }

  # -underscore gives _foo_ style for <u> underline, though it seems to need
  # -with_backspaces to come out.  It doesn't use backspaces it seems,
  # unlike the name would suggest ...

  # 'lynx_options' not documented ...
  return (@command, @{$option->{'lynx_options'} || []});
}

1;
__END__

=head1 NAME

HTML::FormatText::Lynx - format HTML as plain text using lynx

=head1 SYNOPSIS

 use HTML::FormatText::Lynx;
 $text = HTML::FormatText::Lynx->format_file ($filename);
 $text = HTML::FormatText::Lynx->format_string ($html_string);

 $formatter = HTML::FormatText::Lynx->new (rightmargin => 60);
 $tree = HTML::TreeBuilder->new_from_file ($filename);
 $text = $formatter->format ($tree);

=head1 DESCRIPTION

C<HTML::FormatText::Lynx> turns HTML into plain text using the C<lynx> program.

=over 4

L<http://lynx.isc.org/>

=back

The module interface is compatible with formatters like C<HTML::FormatText>,
but all parsing etc is done by lynx.

See C<HTML::FormatExternal> for the formatting functions and options, all of
which are supported by C<HTML::FormatText::Lynx>, with the following caveats

=over 4

=item C<leftmargin>, C<rightmargin>

Prior to the C<-nomargins> option of Lynx 2.8.6dev.12 (June 2005) an
additional 3 space margin is always applied within the requested left and
right positions.

=item C<input_charset>, C<output_charset>

Note that "latin-1" etc is not accepted, it must be "iso-8859-1" etc.

=back

=head2 Extra Options

=over 4

=item C<justify> (boolean)

If true then C<-justify> is passed to lynx to get all lines in the paragraph
padded out with extra spaces to the given C<rightmargin> or default width.

=back

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
