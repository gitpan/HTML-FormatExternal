#!/usr/bin/perl

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

use strict;
use warnings;
use Module::Load;
use Data::Dumper;
use FindBin qw($Bin);

my $class;
#$class = 'HTML::FormatText::Elinks';
$class = 'HTML::FormatText::WithLinks';
$class = 'HTML::FormatText::WithLinks::AndTables';
$class = 'HTML::FormatText::W3m';
$class = 'HTML::FormatText';
$class = 'HTML::FormatText::Lynx';
$class = 'HTML::FormatText::Netrik';
$class = 'HTML::FormatText::Links';
$class = 'HTML::FormatText::Html2text';
Module::Load::load ($class);



{
  my $filename = "$Bin/x.html";
  # $filename = "/tmp/z.html";
  my $str = $class->format_file
    ($filename,
     rightmargin => 60,
     # leftmargin => 20,
     justify => 1,

     # input_charset => 'ascii',
     # input_charset => 'shift-jis',
     # input_charset => 'iso-8859-1',
     # input_charset => 'utf-8',
     output_charset => 'iso-8859-1',
     # output_charset => 'ascii',
     # output_charset => 'ANSI_X3.4-1968',
     # output_charset => 'utf-8'
     lynx_options => [ '-underscore',
#                        '-underline_links',
                       '-with_backspaces',
                     ],
     justify => 1,
    );
  $Data::Dumper::Useqq = 1;
  $Data::Dumper::Purity = 1;
  print "$class\n";
  print $str;
  print Dumper($str);
  print "utf8 flag ",(utf8::is_utf8($str) ? 'yes' : 'no'), "\n";
  exit 0;
}

{
  require I18N::Langinfo;
  require POSIX;
  POSIX::setlocale (POSIX::LC_CTYPE(), "C");
  my $charset = I18N::Langinfo::langinfo (I18N::Langinfo::CODESET());
  print "charset $charset\n";
  exit 0;
}
{
  foreach my $class (qw(HTML::FormatText::Elinks
                        HTML::FormatText::Html2text
                        HTML::FormatText::Lynx
                        HTML::FormatText::Links
                        HTML::FormatText::Netrik
                        HTML::FormatText::W3m
                        HTML::FormatText::Zen)) {
    system "perl", "-Mblib", "-M$class", "-e", "print 'ok $class\n'";
  }
  exit 0;
}

{
  print $class->program_full_version,"\n";
  print $class->program_version,"\n";
  exit 0;
}

{
  require HTML::FormatText::Lynx;
  print "Lynx ",
    HTML::FormatText::Lynx->program_version,
        " _have_nomargins ",
          (HTML::FormatText::Lynx->_have_nomargins?"yes":"no"),"\n";

  require HTML::FormatText::Html2text;
  print "Html2text ",
    HTML::FormatText::Html2text->program_version,
        " _have_ascii ",
          (HTML::FormatText::Html2text->_have_ascii?"yes":"no"),"\n";

  require HTML::FormatText::Links;
  print "Links ",
    HTML::FormatText::Links->program_version,
        " _have_html_margin ",
          (HTML::FormatText::Links->_have_html_margin?"yes":"no"),"\n";

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


