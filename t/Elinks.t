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
use HTML::FormatText::Elinks;
use Test::More tests => 3;

## no critic (ProtectPrivateSubs)

is (HTML::FormatText::Elinks::_quote_config_stringarg(''),
    "''");
is (HTML::FormatText::Elinks::_quote_config_stringarg('abc'),
    "'abc'");
is (HTML::FormatText::Elinks::_quote_config_stringarg("x'y'z"),
    "'x\\'y\\'z'");

exit 0;
