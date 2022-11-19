#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Module::Loader;

my $loader = Module::Loader->new()
  || BAIL_OUT( "Can't instantiate Module::Loader" );

my @modules = sort $loader->find_modules( 'App::TestMLFP::Plugin' );
is_deeply(
    \@modules,
    [ 'App::TestMLFP::Plugin::A', 'App::TestMLFP::Plugin::C' ],
    'found expected modules'
);

