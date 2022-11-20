package Module::Loader::PIR::PathList;

{
    package # avoid CPAN indexing
      Module::Loader::PIR::PathList::Entry;

    use overload
      '-X'     => '_statit',
      'bool'   => sub { 1 },
      '""'     => sub { $_[0]->{path} },
      fallback => 1,
      ;

    sub _croak {
        require Carp;
        goto \&Carp::croak;
    }

    sub new {
        my ( $class, $fs, $path, $leaf ) = @_;

        my %self = (
            path   => $path,
            leaf   => $leaf,
            exists => defined $fs && exists $fs->{$leaf} );
        $self{is_dir}  = $self{exists} && defined $fs->{$leaf};
        $self{is_file} = $self{exists} && !defined $fs->{$leaf};
        $self{fs}      = $self{is_dir} ? $fs->{$leaf} : {};

        return bless \%self, $class;
    }

    sub _children {
        my $self = shift;

        return map { __PACKAGE__->new( $self->{fs}, "$self->{path}/$_", $_ ) } keys %{ $self->{fs} };
    }

    sub _statit {
        my ( $self, $op ) = @_;
        if    ( $op eq 'e' ) { return $self->{exists} }
        if    ( $op eq 'l' ) { return 0; }
        if    ( $op eq 'r' ) { return 1; }
        elsif ( $op eq 'd' ) { return $self->{is_dir} }
        elsif ( $op eq 'f' ) { return $self->{is_file} }
        else                 { _croak( "unsupported file test: -$op\n" ) }
    }
}

use File::Spec::Functions qw/ splitdir splitpath /;
use parent 'Path::Iterator::Rule';

sub _deconstruct_path {
    my $path = shift;
    my ( $volume, $directories, $file ) = splitpath( $path );
    substr( $directories, -1, 1, '' ) if substr( $directories, -1, 1 ) eq '/';
    return ( $volume, $file, splitdir( $directories ) );
}

sub new {
    my $class = shift;
    my @paths = @_;
    my %fs;

    # all paths are files. let's create our "filesystem"!
    for my $path ( @paths ) {
        my ( $volume, $file, @dirs ) = _deconstruct_path( $path );
        my $ref = \%fs;
        for my $entry ( $volume, @dirs ) {
            $ref->{$entry} = {} if !exists $ref->{$entry};
            $ref = $ref->{$entry};
        }
        $ref->{$file} = undef;
    }

    my $self = $class->SUPER::new();
    $self->{_fs} = \%fs;

    return $self;
}

sub _objectify {
    my ( $self, $path ) = @_;

    my ( $volume, $file, @dirs ) = _deconstruct_path( $path );
    my $ref = $self->{_fs};
    for my $entry ( $volume, @dirs ) {
        $ref = undef, last
          if !exists $ref->{$entry};
        $ref = $ref->{$entry};
    }

    return Module::Loader::PIR::PathList::Entry->new( $ref, $path, $file );
}

sub _children {
    my ( $self, $path ) = @_;
    return map { [ $_->{leaf}, $_ ] } $path->_children;
}

sub _defaults {
    return (
        _stringify      => 0,
        follow_symlinks => 1,
        depthfirst      => 0,
        sorted          => 1,
        loop_safe       => 1,
        error_handler   => sub { die sprintf( "%s: %s", @_ ) },
        visitor         => undef,
    );
}

sub _fast_defaults {

    return (
        _stringify      => 0,
        follow_symlinks => 1,
        depthfirst      => -1,
        sorted          => 0,
        loop_safe       => 0,
        error_handler   => undef,
        visitor         => undef,
    );
}

sub _iter {
    my $self     = shift;
    my $defaults = shift;
    $defaults->{loop_safe} = 0;
    $self->SUPER::_iter( $defaults, @_ );
}

1;
