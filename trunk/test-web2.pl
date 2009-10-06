
use Scaffold::Server;

main: {

    my $server = Scaffold::Server->new(
        -engine => 'CGI',
        -locataions => {
            '/'       => 'Site::Root',
            '/photos' => 'Site::Photos',
        },
        -configs => {
            
        },
        -plugins => 'cache session',
        -render => 'TT',
    );

    $server->dispatch();

}

