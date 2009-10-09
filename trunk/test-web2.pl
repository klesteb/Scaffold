
use Scaffold::Server;
use Scaffold::Render;
use Scaffold::Cache::Memcached;

main: {

    my $server = Scaffold::Server->new(
        engine => {
            module => 'ServerSimple',
            args => {
                port => 8080,
            }
        },
        locataions => {
            '/'       => 'Site::Root',
            '/photos' => 'Site::Photos',
        },
        configs => {
            
        },
        plugins => [
            'Site::Plugins::Test',
        ],
        cache => Scaffold::Cache::Memcached->new(
            server => 'localhost',
            port   => '12211',
        ),
        render => Scaffold::Render->new(),
        session => 'Scaffold::Session::Manager',
    );

    $server->engine->run();

}

