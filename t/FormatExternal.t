#!/usr/bin/perl

# Copyright 2008 Kevin Ryde

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
use Test::More tests => 67;

ok ($HTML::FormatExternal::VERSION >= 11);
ok (HTML::FormatExternal->VERSION  >= 11);

sub is_undef_or_string {
  my ($obj) = @_;
  return ! defined $obj || ! ref $obj;
}

sub is_undef_or_one_line_string {
  my ($obj) = @_;
  if (! defined $obj) { return 1; }
  if (ref $obj) { return 0; }
  if ($obj =~ /\n/) { return 0; }
  return 1;
}

foreach my $class (qw(HTML::FormatText::Elinks
                      HTML::FormatText::Links
                      HTML::FormatText::Lynx
                      HTML::FormatText::Netrik
                      HTML::FormatText::W3m
                      HTML::FormatText::Zen)) {
  diag $class;
  eval "require $class"
    or die $@;

  ok ($class->VERSION == $HTML::FormatExternal::VERSION);
  { no strict 'refs';
    ok (${"${class}::VERSION"} == $HTML::FormatExternal::VERSION); }


  #
  # program_full_version
  #
  { my $version = $class->program_full_version;
    require Data::Dumper;
    ok (is_undef_or_string($version),
        "program_full_version() from class ".Data::Dumper::Dumper($version));
  }
  { my $formatter = $class->new;
    my $version = $formatter->program_full_version;
    ok (is_undef_or_string($version),
        "program_full_version() from obj ".Data::Dumper::Dumper($version));
  }

  #
  # program_version
  #

  require Data::Dumper;
  { my $version = $class->program_version();
    ok (is_undef_or_one_line_string($version),
        "$class program_version() from class ".Data::Dumper::Dumper($version));
  }
  { my $formatter = $class->new;
    my $version = $formatter->program_version();
    ok (is_undef_or_one_line_string($version),
        "$class program_version() from obj ".Data::Dumper::Dumper($version));
  }


 SKIP: {
    if (! defined $class->program_full_version) {
      skip "$class program not available", 4;
    }

    { my $html = '<html><body>Hello</body><html>';

      my $str = $class->format_string ($html);
      like ($str, qr/Hello/,
            "$class through class");

      $str = $class->format_string ($html, leftmargin => 0);
      like ($str, qr/^Hello/m,  # /m to allow leading blank lines
            "$class through class, with leftmargin 0");

      my $formatter = $class->new;
      $str = $formatter->format ($html);
      like ($str, qr/Hello/,
            "$class through formatter object");

    SKIP: {
        eval { require HTML::TreeBuilder }
          or skip 'HTML::TreeBuilder not available', 1;

        my $tree = HTML::TreeBuilder->new_from_content ($html);
        $str = $formatter->format ($tree);
        like ($str, qr/Hello/,
              "$class through formatter object on TreeBuilder");
      }
    }

    if ($class !~ /Zen/) { # doesn't support rightmargin

      my $html = '<html><body>123 567 9012 abc def ghij</body><html>';
      my $str = $class->format_string ($html,
                                       leftmargin => 0,
                                       rightmargin => 12);
      like ($str, qr/^123 567 9012$/m,  # /m to allow leading blank lines
            "$class through class, with leftmargin 0 rightmargin 12");
    }
  }
}

exit 0;
