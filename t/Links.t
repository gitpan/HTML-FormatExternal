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
use HTML::FormatText::Links;
use Test::More tests => 2;

## no critic (ProtectPrivateSubs)

is (HTML::FormatText::Links::_links_mung_charset ('latin-1'),
    "latin1");
is (HTML::FormatText::Links::_links_mung_charset ('LATIN-2'),
    "LATIN2");

exit 0;
