#!/usr/bin/perl -w

# Copyright 2008, 2009, 2010, 2011, 2012, 2013 Kevin Ryde

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
# You should have received a copy of the GNU General Public License along
# with HTML-FormatExternal.  If not, see <http://www.gnu.org/licenses/>.

use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile
  (NAME         => 'HTML::FormatExternal',
   ABSTRACT     => 'HTML to text formatting using external programs.',
   VERSION_FROM => 'lib/HTML/FormatExternal.pm',
   MIN_PERL_VERSION => '5.006',
   PREREQ_PM    => {
                    'Encode'    => 0,
                    'IPC::Run'  => 0,
                    'URI::file' => 0.08, # version 0.08 for new_abs()
                    
                    # Version 0.18 for overloaded eq() which File::Copy
                    # calls :-(.  Only actually needed for the "base" option
                    # with input from a file.
                    'File::Temp' => 0.18,

                    # Version 0.80 for File::Spec->devnull(), which came
                    # with Perl 5.6.0.
                    'File::Spec' => 0.80,

                    # only for the t/*.t tests
                    'Test::More' => 0,
                   },

   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,

   META_MERGE =>
   { resources =>
     { homepage => 'http://user42.tuxfamily.org/html-formatexternal/index.html',
       license  => 'http://www.gnu.org/licenses/gpl.html',
     },
     no_index => { directory=>['devel'] },

     optional_features =>
     { maximum_tests =>
       { description => 'Have "make test" do as much as possible.',
         requires => { 'HTML::TreeBuilder' => 0,
                     },
       },
     },
   },
  );
