
use Scaffold::Server;
use Scaffold::Render;
use Scaffold::Session;
use Scaffold::Cache::Memcached;

main: {

    my $server = Scaffold::Server->new(
        -engine => {
            module => 'ServerSimple',
            args => {
                port => 8080,
            }
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
        -session => {
            -store => HTTP::Session::Store::Memcached->new(
                memd => Cache::Memcached->new(
                    servers => ['127.0.0.1:11211']
                ),
            ),
            -state => HTTP::Session::State::Cookie->new(
                cookie_key => ''
            )
        }
    );

    $server->engine->run();

}

