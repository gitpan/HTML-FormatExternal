#!/usr/bin/perl

# Copyright 2008, 2009, 2010 Kevin Ryde

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
use 5.008;
use Encode;
use HTML::FormatExternal;
use Test::More tests => 24;

BEGIN { SKIP: { eval 'use Test::NoWarnings; 1'
                  or skip 'Test::NoWarnings not available', 1; } }

use HTML::FormatText::Elinks;
use HTML::FormatText::Links;
use HTML::FormatText::Lynx;
use HTML::FormatText::Netrik;
use HTML::FormatText::W3m;
use HTML::FormatText::Zen;


# links: U+263A input becomes ":-)" in latin1 output
#
SKIP: {
  my $class = 'HTML::FormatText::Links';
  $class->program_version or skip "$class not available", 1;
  diag $class;

  my $input_charset = 'utf-8';
  my $output_charset = 'latin-1';
  my $html = "<html><body>\x{263A}</body></html>";
  $html = Encode::encode ($input_charset, $html);
  my $str = $class->format_string
    ($html,
     input_charset => $input_charset,
     output_charset => $output_charset);
  like ($str, qr/\Q:-)/,
        "$class U+263A smiley $input_charset -> $output_charset");
}

# lynx undocumented 'justify' option
#
SKIP: {
  my $class = 'HTML::FormatText::Lynx';
  $class->program_version or skip "$class not available", 1;
  diag $class;

  my $html = "<html><body>x y z aaaa</body></html>";
  $html = Encode::encode ('utf-8', $html);
  my $str = $class->format_string
    ($html,
     leftmargin => 0,
     rightmargin => 7,
     justify => 1);
  like ($str, qr/^x  y  z$/m, "$class justify option");
}

SKIP: foreach my $class ('HTML::FormatText::Elinks',
                         'HTML::FormatText::Links',
                         'HTML::FormatText::Lynx',
                         # 'HTML::FormatText::Netrik',  # no charsets
                         'HTML::FormatText::W3m',
                         # 'HTML::FormatText::Zen',  # no charsets
                        ) {
  diag $class;
  $class->program_full_version or skip "$class program not available", 1;

  my $input_charset = 'utf-8';
  my $output_charset = 'iso-8859-1';
  my $html = "<html><body>\x{B0}</body></html>";
  $html = Encode::encode ($input_charset, $html);
  is (length($html), 12+2+14);
  my $str = $class->format_string
    ($html,
     input_charset => $input_charset,
     output_charset => $output_charset);
  my $degree_bytes = "\x{B0}";
  $degree_bytes = Encode::encode ($output_charset, $degree_bytes);
  is (length($degree_bytes), 1);
  like ($str, qr/\Q$degree_bytes/,
        "$class degree sign $input_charset -> $output_charset");
}

SKIP: foreach my $class ('HTML::FormatText::Elinks',
                         # 'HTML::FormatText::Links',  # no utf-8 output
                         'HTML::FormatText::Lynx',
                         # 'HTML::FormatText::Netrik',  # no charsets
                         'HTML::FormatText::W3m',
                         # 'HTML::FormatText::Zen',  # no charsets
                        ) {
  diag $class;
  $class->program_full_version or skip "$class program not available", 2;

  my $input_charset = 'iso-8859-1';
  my $output_charset = 'utf-8';
  my $html = "<html><body>\x{B0}</body></html>";
  $html = Encode::encode ($input_charset, $html);
  is (length($html), 12+1+14);
  my $str = $class->format_string
    ($html,
     input_charset => $input_charset,
     output_charset => $output_charset);
  my $degree_bytes = "\x{B0}";
  $degree_bytes = Encode::encode ($output_charset, $degree_bytes);
  is (length($degree_bytes), 2);
  like ($str, qr/\Q$degree_bytes/,
        "$class degree sign $input_charset -> $output_charset");
}

exit 0;
