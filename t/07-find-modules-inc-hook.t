#! perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;
use Module::Loader;

{
    package IncHook;
    sub new          { return bless {}, shift }
    sub IncHook::INC { }
    sub files {
        qw(
          My/Monkey/Plugin/Bonobo.pm
          My/Monkey/Plugin/Mandrill.pm
          My/Monkey/Plugin/Bonobo/Utilities.pm
        );
    }
}

unshift @INC, IncHook->new;

my ( $loader, @modules );

$loader = Module::Loader->new()
  || BAIL_OUT( "Can't instantiate Module::Loader" );

@modules = $loader->find_modules( 'My::Monkey::Plugin' );

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Bonobo' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo"
);

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Bonobo::Utilities' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo::Utilities"
);

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Mandrill' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo::Utilities"
);

@modules = $loader->find_modules( 'My::Monkey::Plugin', { max_depth => 1 } );

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Bonobo' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo"
);

ok(
    !grep( { $_ eq 'My::Monkey::Plugin::Bonobo::Utilities' } @modules ),
    "We should NOT find My::Monkey::Plugin::Bonobo::Utilities"
);

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Mandrill' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo::Utilities"
);

@modules = $loader->find_modules( 'My::Monkey::Plugin' );

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Bonobo' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo"
);

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Bonobo::Utilities' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo::Utilities"
);

ok(
    grep( { $_ eq 'My::Monkey::Plugin::Mandrill' } @modules ),
    "We should find My::Monkey::Plugin::Bonobo::Utilities"
);

done_testing;
