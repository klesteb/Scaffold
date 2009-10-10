
use lib 'lib';
use lib '../App';

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
            '/'       => 'App::HelloWorld',
        },
    );

    $server->engine->run();

}

