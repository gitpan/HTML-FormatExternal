# Copyright 2008, 2009 Kevin Ryde

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

package HTML::FormatExternal;
# Perl6::Slurp demands 5.8 anyway, don't think need to ask for 5.8 here to
# be sure of getting multi-arg open() of piped command in that module
# use 5.008;
use 5.006;
use strict;
use warnings;
use Carp;


our $VERSION = 14;

# set this to 1 for some diagnostic prints, set to 2 to preserve tempfiles
# (also possible with the usual File::Temp settings)
#
use constant DEBUG => 0;

sub new {
  my ($class, %self) = @_;
  return bless \%self, $class;
}
sub format {
  my ($self, $html) = @_;
  if (ref $html) { $html = $html->as_HTML; }
  return $self->format_string ($html, %$self);
}

# format_string() includes some secret experimental wide-char handling: if
# the input string is wide then it's passed to and from the program in the
# specified input_charset and output_charset, but then decoded back to a
# wide string at the end.  The charsets default to utf-8 input, and to
# _WIDE_CHARSET for output.  Links.pm and Html2text.pm override this default
# _WIDE_CHARSET according to what output they're able to produce.
# 
use constant _WIDE_CHARSET => 'UTF-8';

# format_string() takes the easy approach of putting the string in a temp
# file and letting format_file() do the real work.  The formatter programs
# can generally read stdin and write stdout, so could do that with select()
# to simultaneously write and read back.
#
sub format_string {
  my ($class, $html_str, %options) = @_;

  require File::Temp;
  my $fh = File::Temp->new;
  if (DEBUG) {
    print "FormatExternal temp file ",$fh->filename,"\n";
    if (DEBUG >= 2) { $fh->unlink_on_destroy(0); }
  }

  if (utf8::is_utf8 ($html_str)) {
    if (! exists $options{'input_charset'}) {
      $options{'input_charset'} = 'UTF-8';
    }
    if (! exists $options{'output_charset'}) {
      $options{'output_charset'} = $class->_WIDE_CHARSET;
    }
    my $charset = $options{'input_charset'};
    my $layer = ":encoding($charset)";
    binmode ($fh, $layer) or croak "Cannot set coding $layer";
  }

  $fh->autoflush(1);
  print $fh $html_str or croak "Cannot write temp file";

  my $str = $class->format_file ($fh->filename, %options);

  if (utf8::is_utf8 ($html_str)) {
    $str = Encode::decode ($options{'output_charset'}, $str);
  }
  return $str;
}

# Left margin is synthesized by adding spaces afterwards because the various
# programs have pretty variable support for a specified margin.
#   * w3m doesn't seem to have a left margin option at all
#   * lynx has one but it's too well hidden in its style sheet or something
#   * elinks has document.browse.margin_width but it's limited to 8 or so
#   * netrik doesn't seem to have one at all
#
sub format_file {
  my ($class, $filename, %options) = @_;

  # If neither leftmargin nor rightmargin are specified then '_width' is
  # unset and the _crunch_command() funcs leave it to the program defaults.
  #
  # If either leftmargin or rightmargin are set then '_width' is established
  # and the _crunch_command() funcs use it and and zero left margin, then
  # the actual left margin is applied below.
  #
  # The DEFAULT_LEFTMARGIN and DEFAULT_RIGHTMARGIN establish the defaults
  # when just one of the two is set.  Not great hard coding those values,
  # but the programs don't have anything good to set one but not the other.
  #
  my $leftmargin  = $options{'leftmargin'};
  my $rightmargin = $options{'rightmargin'};
  if (defined $leftmargin || defined $rightmargin) {
    if (! defined $leftmargin)  { $leftmargin  = $class->DEFAULT_LEFTMARGIN; }
    if (! defined $rightmargin) { $rightmargin = $class->DEFAULT_RIGHTMARGIN; }
    $options{'_width'} = $rightmargin - $leftmargin;
  }

  my @command = ('-|', $class->_crunch_command(\%options), $filename);
  my $env = $options{'ENV'} || {};
  if (DEBUG) {
    require Data::Dumper;
    print Data::Dumper->new([\@command],['command'])->Dump;
    if (%$env) { print Data::Dumper->new($env,['env'])->Dump; }
  }

  require Perl6::Slurp;
  my $str = do {
    local %ENV = %ENV;
    @ENV{keys %$env} = values %$env; # overrides
    Perl6::Slurp::slurp (@command);
  };

  if (defined $leftmargin) {
    my $fill = ' ' x $leftmargin;
    $str =~ s/^(.)/$fill$1/mg;  # non-empty lines only
  }
  return $str;
}

sub _run_version {
  my ($self_or_class, @command) = @_;
  require Perl6::Slurp;

  my $version = do {
    # no warning suppression when debugging
    local $SIG{__WARN__} = (DEBUG ? $SIG{__WARN__}
                            : \&_warn_suppress_exec);
    eval { Perl6::Slurp::slurp ('-|', @command) }
  };

  # strip blank lines at end of lynx, maybe others
  if (defined $version) { $version =~ s/\n{2,}$/\n/s; }
  return $version;
}

# In Perl6::Slurp version 0.03 open() gives its usual warning if it can't
# run the program, but Perl6::Slurp then croaks with that same message.
# Suppress the warning in the interests of avoiding duplication.
#
sub _warn_suppress_exec {
  $_[0] =~ /Can't exec/
    or warn $_[0];
}

1;
__END__

=head1 NAME

HTML::FormatExternal - HTML to text formatting using external programs

=head1 DESCRIPTION

This is a collection of the following formatter modules turning HTML into
plain text by dumping it through the respective external programs.

    HTML::FormatText::Elinks
    HTML::FormatText::Html2text
    HTML::FormatText::Links
    HTML::FormatText::Lynx
    HTML::FormatText::Netrik
    HTML::FormatText::W3m
    HTML::FormatText::Zen

The module interfaces are compatible with C<HTML::Formatter> modules like
C<HTML::FormatText>, but the programs do all the work.

Common formatting options are used where possible, like C<leftmargin> and
C<rightmargin>, so just by switching the class you can use a different
program (or the plain C<HTML::FormatText>) according to personal preference,
or strengths and weaknesses, or what you've got.

There's nothing particularly difficult about piping through these programs,
but a unified interface hides details like how to set margins and how to
force input or output charsets.

=head1 FUNCTIONS

Each of the classes above provide the following functions.  The C<XXX> in
the class names here is a placeholder for any of C<Elinks>, C<Lynx>, etc as
above.

=head2 Formatter Compatible Functions

=over 4

=item C<< $text = HTML::FormatText::XXX->format_file ($filename, key=>value,...) >>

=item C<< $text = HTML::FormatText::XXX->format_string ($html_string, key=>value,...) >>

Run the formatter program over a file or string with the given options and
return the formatted result as a string.  See L</OPTIONS> below for
available options.  For example,

    $text = HTML::FormatText::Lynx->format_file ('/my/file.html');

    $text = HTML::FormatText::W3m->format_string
      ('<html><body> <p> Hello world! </p </body></html>');

=item C<< $formatter = HTML::FormatText::XXX->new (key=>value, ...) >>

Create a formatter object with the given options.  In the current
implementation an object doesn't do much more than remember the options for
future use.

    $formatter = HTML::FormatText::Elinks->new(rightmargin => 60);

=item C<< $text = $formatter->format ($tree_or_string) >>

Run the C<$formatter> program on a C<HTML::TreeBuilder> tree or a string,
using the options in C<$formatter>, and return the result as a string.

A TreeBuilder argument (ie. a C<HTML::Element>) is for compatibility with
C<HTML::Formatter>.  The tree is simply turned into a string with
C<< $tree->as_HTML >> to pass to the program, so if you've got a string
already then give that instead of a tree.

=back

=head2 Extra Functions

=over 4

=item C<< HTML::FormatText::XXX->program_version () >>

=item C<< HTML::FormatText::XXX->program_full_version () >>

=item C<< $formatter->program_version () >>

=item C<< $formatter->program_full_version () >>

Return the version number of the formatter program as reported by its
C<--version> or similar option.  If the formatter program is not available
the return is C<undef>.

C<program_version> is the number alone.  C<program_full_version> is the
entire output, which may include build options, copyright notice, etc.

    $str = HTML::FormatText::Lynx->program_version();
    # eg. "2.8.7dev.10"

    $str = HTML::FormatText::W3m->program_full_version();
    # eg. "w3m version w3m/0.5.2, options lang=en,m17n,image,..."

The version number of the Perl module itself is available with the usual
C<< HTML::FormatText::Netrik->VERSION >> or C<< $formatter->VERSION >>, see
L<UNIVERSAL>.

=back

=head1 CHARSETS

A file passed to the formatters is interpreted in the charset of a
C<< <meta> >> within the HTML, or latin-1 per the HTML specs, or as forced
by the C<input_charset> option below.

A string input should be bytes the same as a file, not Perl wide chars.
(There's some secret experimental encode/decode for wide chars, but better
let C<HTML::Formatter> take the lead on how that might work.)

The result string is bytes similarly, encoded in whatever the respective
programs produce.  This may be the locale charset; you can force it with the
C<output_charset> option to be sure.

=head1 OPTIONS

The following options can be given.  The defaults are whatever the
respective programs do.  The programs generally read their config files when
dumping, so the defaults and formatting details may follow your personal
settings (usually a good thing).

=over 4

=item C<< leftmargin => INTEGER >>

=item C<< rightmargin => INTEGER >>

The column numbers for the left and right hand ends of the text.
C<leftmargin> 0 means no padding on the left.  C<rightmargin> is the text
width, so for instance 60 would mean the longest line is 60 characters
(inclusive of any C<leftmargin>).  These options are compatible with
C<HTML::FormatText>.

C<rightmargin> is not necessarily a hard limit.  Some of the programs will
exceed it in a HTML literal C<< <pre> >>, or a run of C<&nbsp;>, or similar.

=item C<< input_charset => STRING >>

Force the HTML input to be interpreted as bytes of the given charset,
including ignoring any C<< <meta> >> within the HTML.

=item C<< output_charset => STRING >>

Force the text output to be encoded as of the given charset.  The program
defaults vary, but usually follow the locale.

=back

=head1 FUTURE

There's nothing done with errors or warning messages from the formatters.
Generally they make a best effort on doubtful HTML, but fatal errors like
bad options or missing libraries will probably be trapped in the future.

C<elinks> (from Aug 2008) and C<netrik> can produce ANSI escapes for
colours, underline, etc, and C<html2text> can produce TTY style backspacing.
This might be good for text destined for a tty or further crunching.
Perhaps an C<ansi> or C<tty> option could enable this, where possible, but
for now it's deliberately turned off in those programs to keep the default
straightforward.

=head1 SEE ALSO

L<HTML::FormatText::Elinks>,
L<HTML::FormatText::Html2text>,
L<HTML::FormatText::Links>,
L<HTML::FormatText::Netrik>,
L<HTML::FormatText::Lynx>,
L<HTML::FormatText::W3m>,
L<HTML::FormatText::Zen>,

L<HTML::FormatText>,
L<HTML::FormatText::WithLinks>,
L<HTML::FormatText::WithLinks::AndTables>

=head1 HOME PAGE

L<http://www.geocities.com/user42_kevin/html-formatexternal/index.html>

=head1 LICENSE

Copyright 2008, 2009 Kevin Ryde

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
