#!perl -w

use strict;
use Test::More 0.88 tests => 4;

use Module::Loader::PIR::PathList;

my @files = sort qw(
      Monkey/Plugin/Bonobo.pm
      Monkey/Plugin/Mandrill.pm
      Monkey/Plugin/Bonobo/Utilities.pm
);

my @dirs = sort qw(
      Monkey
      Monkey/Plugin
      Monkey/Plugin/Bonobo
);

my @all = sort qw(
      Monkey
      Monkey/Plugin
      Monkey/Plugin/Bonobo.pm
      Monkey/Plugin/Mandrill.pm
      Monkey/Plugin/Bonobo
      Monkey/Plugin/Bonobo/Utilities.pm
);

my $rule = Module::Loader::PIR::PathList->new( @files  );
is_deeply( [ sort $rule->all('Monkey') ] , \@all, 'all' );
is_deeply( [ sort $rule->clone->dir->all('Monkey') ], \@dirs, 'dirs' );
is_deeply( [ sort $rule->clone->file->all('Monkey') ], \@files, 'files' );
is_deeply( [ sort $rule->clone->perl_module->all('Monkey') ], \@files, 'perl modules' );

done_testing;
