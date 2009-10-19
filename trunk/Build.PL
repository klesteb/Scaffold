use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Scaffold',
    license             => 'perl',
    dist_author         => 'Kevin L. Esteb <kesteb@wsipc.org>',
    dist_version_from   => 'lib/Scaffold/Base.pm',
    build_requires => {
        'Badger'        => '0.06',
        'HTTP::Engine'  => '0.02',
        'HTTP::Session' => '0.32',
        'KeyedMutex'    => '0.06',
    },
    add_to_cleanup      => [ 'Scaffold-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
