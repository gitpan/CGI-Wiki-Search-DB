#!/usr/bin/perl
use warnings;
use strict;

use Module::Build;

Module::Build->new(
    module_name => 'CGI::Wiki::Search::DB',
    license => 'perl',
    requires => {
      'CGI::Wiki' => 0,
      'DBI'       => 0,
    },
    create_makefile_pl => 'traditional',
    create_readme => 1,
)->create_build_script;

