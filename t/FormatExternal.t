#!/usr/bin/perl

# Copyright 2008, 2009 Kevin Ryde

# This file is part of HTML-FormatExternal.
#
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
# You can get a copy of the GNU General Public License online at
# http://www.gnu.org/licenses.

use strict;
use warnings;
use HTML::FormatExternal;
use Test::More tests => 2 + 7*11;

my $want_version = 14;
ok ($HTML::FormatExternal::VERSION >= $want_version,
    'VERSION variable');
ok (HTML::FormatExternal->VERSION  >= $want_version,
    'VERSION class method');
HTML::FormatExternal->VERSION ($want_version);

## no critic (ProtectPrivateSubs)


# Cribs:
#
# Test::More::like() ends up spinning a qr// through a further /$re/ which
# loses any /m modifier, prior to perl 5.10.0 at least.  So /m is avoided in
# favour of some (^|\n) and ($|{\r\n]) forms.


sub is_undef_or_string {
  my ($obj) = @_;
  if (! defined $obj) { return 1; }
  if (ref $obj) { return 0; }
  if ($obj eq '') { return 0; } # disallow empty
  return 1;
}

sub is_undef_or_one_line_string {
  my ($obj) = @_;
  if (! defined $obj) { return 1; }
  if (ref $obj) { return 0; }
  if ($obj eq '') { return 0; } # disallow empty
  if ($obj =~ /\n/) { return 0; }
  return 1;
}

foreach my $class (qw(HTML::FormatText::Elinks
                      HTML::FormatText::Html2text
                      HTML::FormatText::Links
                      HTML::FormatText::Lynx
                      HTML::FormatText::Netrik
                      HTML::FormatText::W3m
                      HTML::FormatText::Zen)) {
  diag $class;
  eval "require $class"
    or die $@;

  is ($class->VERSION,
      $HTML::FormatExternal::VERSION,
      "$class VERSION method");
  is (do { no strict 'refs'; ${"${class}::VERSION"} },
      $HTML::FormatExternal::VERSION,
      "$class VERSION variable");

  #
  # program_full_version
  #
  { my $version = $class->program_full_version;
    require Data::Dumper;
    diag ("$class program_full_version ", Data::Dumper::Dumper($version));
    ok (is_undef_or_string($version),
        'program_full_version() from class');
  }
  { my $formatter = $class->new;
    my $version = $formatter->program_full_version;
    ok (is_undef_or_string($version),
        'program_full_version() from obj');
  }

  #
  # program_version
  #
  # Netrik is an empty string as it doesn't seem to print its version,
  # others have to be non-empty
  #
  { my $version = $class->program_version();
    require Data::Dumper;
    diag ("$class program_version ", Data::Dumper::Dumper($version));
    ok (is_undef_or_one_line_string($version),
        "$class program_version() from class");
  }
  { my $formatter = $class->new;
    my $version = $formatter->program_version();
    ok (is_undef_or_one_line_string($version),
        "$class program_version() from obj");
  }


 SKIP: {
    if (! defined $class->program_full_version) {
      skip "$class program not available", 5;
    }

    { my $str = $class->format_string ('<html><body>Hello</body><html>');
      like ($str, qr/Hello/,
            "$class through class");
    }
    { my $formatter = $class->new;
      my $str = $formatter->format ('<html><body>Hello</body><html>');
      like ($str, qr/Hello/,
            "$class through formatter object");
    }

  SKIP: {
      eval { require HTML::TreeBuilder }
        or skip 'HTML::TreeBuilder not available', 1;

      my $tree = HTML::TreeBuilder->new_from_content
        ('<html><body>Hello</body><html>');
      my $formatter = $class->new;
      my $str = $formatter->format ($tree);
      like ($str, qr/Hello/,
            "$class through formatter object on TreeBuilder");
    }

  SKIP: {
      if ($class =~ /Lynx/ && ! $class->_have_nomargins()) {
        skip "this Lynx doesn't have -nomargins", 1;
      }
      if ($class =~ /Links/ && ! $class->_have_html_margin()) {
        skip "this links doesn't have -html-margin", 1;
      }

      my $str = $class->format_string ('<html><body>Hello</body><html>',
                                       leftmargin => 0);
      like ($str, qr/(^|\n)Hello/,  # allowing for leading blank lines
            "$class through class, with leftmargin 0");
    }

  SKIP: {
      if ($class =~ /Zen/) {
        skip "$class doesn't support rightmargin", 1;
      }
      if ($class =~ /Lynx/ && ! $class->_have_nomargins()) {
        skip "this Lynx doesn't have -nomargins", 1;
      }
      if ($class =~ /Links/ && ! $class->_have_html_margin()) {
        skip "this links doesn't have -html-margin", 1;
      }

      my $html = '<html><body>123 567 9012 abc def ghij</body><html>';
      my $str = $class->format_string ($html,
                                       leftmargin => 0,
                                       rightmargin => 12);
      { require Data::Dumper;
        my $dumper = Data::Dumper->new([$str],['output']);
        $dumper->Useqq (1);
        diag ($dumper->Dump);
      }
      like ($str, qr/(^|\n)123 567 9012($|[\r\n])/,
            "$class through class, with leftmargin 0 rightmargin 12");
    }
  }
}

exit 0;
