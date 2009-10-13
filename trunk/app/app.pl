
use lib 'lib';
use lib '../lib';
use Scaffold::Server;

main: {

    my $server = Scaffold::Server->new(
        engine => {
            module => 'ServerSimple',
            args => {
                port => 8080,
            }
        },
        locations => {
            '/'            => 'App::HelloWorld',
            '/test'        => 'App::Cached',
            '/robots.txt'  => 'Scaffold::Handler::Robots',
            '/favicon.ico' => 'Scaffold::Handler::Favicon',
            '/static'      => 'Scaffold::Handler::Static',
        },
    );

    $server->engine->run();

}

