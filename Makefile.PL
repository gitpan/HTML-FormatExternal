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
# You should have received a copy of the GNU General Public License along
# with HTML-FormatExternal.  If not, see <http://www.gnu.org/licenses/>.

use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'HTML::FormatExternal',
   ABSTRACT     => 'HTML to text formatting using external programs.',
   VERSION_FROM => 'lib/HTML/FormatExternal.pm',
   MIN_PERL_VERSION => '5.006',
   PREREQ_PM    => {
                    # actually Perl6::Slurp depends on perl 5.8 which has
                    # File::Temp and Test::More builtin, and we probably
                    # want 5.8 for the slurp to use a multi-arg pipe open(),
                    # so probably don't need to list these explicitly
                    #
                    'Encode'     => 0,
                    'File::Temp' => 0,
                    'Test::More' => 0,

                    'Perl6::Slurp' => 0,
                   },

   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,

   META_MERGE
   => { resources
        => { homepage
             => 'http://user42.tuxfamily.org/html-formatexternal/index.html',
           },
        optional_features
        => { maximum_tests
             => { description => 'Have "make test" do as much as possible.',
                  requires => { 'HTML::TreeBuilder' => 0,
                                'Test::NoWarnings'  => 0,
                              },
                },
             maximum_devel
             => { description => 'Stuff used variously for development.',
                  requires => { 'Module::Load' => 0,
                                'I18N::Langinfo' => 0,
                              },
                },
           },
      },
  );
