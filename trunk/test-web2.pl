
use Scaffold::Server;
use Scaffold::Render;
use Scaffold::Session;
use Scaffold::Cache::Memcached;

main: {

    my $server = Scaffold::Server->new(
        -engine => {
            module => 'CGI',
        },
        -locataions => {
            '/'       => 'Site::Root',
            '/photos' => 'Site::Photos',
        },
        -configs => {
            
        },
        -plugins => [
            'Site::Plugins::Test',
        ],
        -render => Scaffold::Render->new(),
        -cache => Scaffold::Cache::Memcached->new(
            -server => 'localhost',
            -port   => '12211',
        ),
        -session => Scaffold::Session::Base->new(
            -storage => Scaffold::Session::Store::Cache->new(
            )
        )
    );

    $server->engine->run();

}

