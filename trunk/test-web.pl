
use Scaffold::Server;
use Scaffold::Dispatch;
use Scaffold::Render::TT;
use Scaffold::CacheManager;
use Scaffold::SessionManager;
use Scaffold::DatabaseManager;

main: {

    my $server = Scaffold::Server->new(
        -engine => Scaffold::Engine::MP20->new(),
        -database => Scaffold::DatabaseManager->new(
            -monitor => My::Database::Monitor->new(
                -database => 'monitor',
                -dbname   => 'username',
                -dbpass   => 'password',
            ),
        ),
        -session  => Scaffold::SessionManager->new(
            -storage => Scaffold::Session::Postgresql->new(
                -database => 'session',
                -dbname   => 'username',
                -dbpass   => 'password',
                -table    => 'session'
            ),
        ),
        -cache => Scaffold::CacheManager->new(
            -storage => Scffold::Cache::Memcached->new(
                -host => 'localhost',
                -port => '1234'
            )
        ),
        -render => Scaffold::Render::TT->new(),
        -dispatch => Scaffold::Dispatch->new(
            '/'       => 'Site::Root',
            '/photos' => 'Site::Photos'
        )
    );

    $server->run();

}

