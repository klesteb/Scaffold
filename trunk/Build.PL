use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Scaffold',
    license             => 'perl',
    dist_author         => 'Kevin L. Esteb <kevin@kesteb.us>',
    dist_version_from   => 'lib/Scaffold.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More'    => '0.00',
        'Pod::Coverage' => '0.00',
    },
    meta_add => {
        resources => {
            homepage   => 'http://scm.kesteb.us/trac',
            repository => 'http://scm.kesteb.us/repos/Scaffold',
        },
    },
    install_requires => {
        'Badger'               => '0.06',
        'Plack'                => '0.9911',
        'Plack::Request'       => '0.9911',
        'HTTP::Session'        => '0.32',
        'KeyedMutex'           => '0.06',
        'Crypt::CBC'           => '2.17',
        'Crypt::OpenSSL::AES'  => '2.10',
        'CGI::Simple::Cookie'  => '1.112',
        'Cache::FastMmap'      => '1.34',
        'Cache::Memcached'     => '1.28',
        'Try::Tiny'            => '0.04',
        'Set::Light'           => 0,
    },
    add_to_cleanup      => [ 'Scaffold-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
