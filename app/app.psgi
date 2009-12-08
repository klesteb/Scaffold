
use lib 'lib';
use lib '../lib';
use Scaffold::Server;
use Scaffold::Render::TT;

my $psgi_handler;

main: {

    my $server = Scaffold::Server->new(
        locations => {
            '/'            => 'App::HelloWorld',
            '/test'        => 'App::Cached',
            '/robots.txt'  => 'Scaffold::Handler::Robots',
            '/favicon.ico' => 'Scaffold::Handler::Favicon',
            '/static'      => 'Scaffold::Handler::Static',
            '/login'       => 'Scaffold::Uaf::Login',
            '/logout'      => 'Scaffold::Uaf::Logout',
        },
        authorization => {
            authenticate => 'Scaffold::Uaf::Manager',
            authorize    => 'Scaffold::Uaf::Authorize',
        },
        render => Scaffold::Render::TT->new(
            include_path => 'html:html/resources/templates',
        ),
    );

    $psgi_hander = $server->engine->psgi_handler();

}

