
use lib 'lib';
use lib '../lib';
use Scaffold::Server;
use Scaffold::Render::TT;

use strict;
use warnings;

my $psgi_handler;

main: {

    my $server = Scaffold::Server->new(
        configs => {
            static_search      => 'html:html/resources',
            uaf_login_wrapper  => 'uaf_wrapper.tt',
            uaf_logout_wrapper => 'uaf_wrapper.tt',
            uaf_denied_wrapper => 'uaf_wrapper.tt',
        },
        locations => [
            {
                route   => qr{^/$},
                handler => 'App::Main',
            },{
               route   => qr{^/robots.txt$},
               handler => 'Scaffold::Handler::Robots',
            },{
               route   => qr{^/favicon.ico$},
               handler => 'Scaffold::Handler::Favicon',
            },{
               route   => qr{^/static/(.*)$},
               handler => 'Scaffold::Handler::Static',
            },{
                route   => qr{^/login/(\w+)$},
                handler => => 'Scaffold::Uaf::Login',
            },{
                route   => qr{^/login$},
                handler => => 'Scaffold::Uaf::Login',
            },{
                route   => qr{^/logout$},
                handler => 'Scaffold::Uaf::Logout',
            }
        ],
        authorization => {
            authenticate => 'Scaffold::Uaf::Manager',
            authorize    => 'Scaffold::Uaf::AuthorizeFactory',
        },
        render => Scaffold::Render::TT->new(
            include_path => 'html:html/resources/templates',
        ),
        lockmgr => Scaffold::Lockmgr::UnixMutex->new(
            key => 1234
        )
    );

    $psgi_handler = $server->engine->psgi_handler();

}

