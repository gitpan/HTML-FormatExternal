#!/usr/bin/perl

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

use strict;
use warnings;
use Module::Load;
use Data::Dumper;
use FindBin qw($Bin);

my $class;
# $class = 'HTML::FormatText::Lynx';
# $class = 'HTML::FormatText::W3m';
#$class = 'HTML::FormatText::Links';
#$class = 'HTML::FormatText::Elinks';
$class = 'HTML::FormatText::Netrik';
Module::Load::load ($class);



{
  my $str = $class->format_file ("$Bin/x.html",
                                  rightmargin => 60,
                                 # leftmargin => 20,
                                 # input_charset => 'iso-8859-1',
                                 # input_charset => 'utf-8',
                                 # output_charset => 'iso-8859-1'
                                 # output_charset => 'utf-8'
                                );
  $Data::Dumper::Useqq = 1;
  $Data::Dumper::Purity = 1;
  print $str;
  print Dumper($str);
  print "utf8 flag ",(utf8::is_utf8($str) ? 'yes' : 'no'), "\n";
  exit 0;
}

{
  my $html_str = <<"HERE";
<html>
<head>
<title>A Page</title>
</head>
<body>
<p> Hello <u>fjkd</u> jfksd jfk \x{263A} sdjkf jsk fjsdk fjskd jfksd jfks djfk sdjfk sdjkf jsdkf jsdk fjksd fjksd jfksd jfksd jfk sdjfk sdjkf sdjkf sdjkbhjhh <a href="world.html">world</a> </p>

<p> \x{263A}\x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} \x{263A}\x{263A}\x{263A} </p>
</body>
</html>
HERE
  print "utf8 flag ",(utf8::is_utf8($html_str) ? 'yes' : 'no'), "\n";

  my $str = $class->format_string ($html_str,
                                   # justify => 1,
                                   rightmargin => 40,
                                   leftmargin => 10,
                                  );
  print $str;
  print Dumper($str);
  print "utf8 flag ",(utf8::is_utf8($str) ? 'yes' : 'no'), "\n";
  exit 0;
}




{
  my $str = $class->format_string
    ('<html><body> <p> Hello </body> </html>');
  print $str;
  exit 0;
}


