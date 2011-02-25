package Scaffold::Server;

our $VERSION = '0.02';

use 5.8.8;
use Try::Tiny;
use Plack::Response;
use Scaffold::Engine;
use Scaffold::Routes;
use Scaffold::Cache::Manager;
use Scaffold::Stash::Manager;
use Scaffold::Render::Default;
use Scaffold::Cache::FastMmap;
use Scaffold::Session::Manager;
use Scaffold::Lockmgr::UnixMutex;

use Scaffold::Class
  version    => $VERSION,
  base       => 'Scaffold::Base',
  accessors  => 'authz engine cache render database plugins request response lockmgr routes',
  mutators   => 'session user',
  filesystem => 'File',
  utils      => 'init_module',
  constants  => 'TRUE FALSE',
  messages => {
      'nomodule'  => "module: %s not loaded, because: %s",
      'nodefine'  => "a handler for \"%s\" was not defined", 
      'noplugin'  => "plugin: %s not initialized, because: %s",
      'nohandler' => "handler: %s for location %s was not loaded, because: %s",
  },
  constant => {
      NODEFINE  => 'scaffold.server.nodefine',
      NOMODULE  => 'scaffold.server.nomodule',
      NOPLUGIN  => 'scaffold.server.noplugin',
      NOHANDLER => 'scaffold.server.nohandler',
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub dispatch {
    my ($self, $request) = @_;

    $self->{request} = $request;
    $self->{response} = Plack::Response->new();

    my $class;
    my $response;
    my $handler = '';
    my @params = ();
    my $url = $request->path_info;
    my $location = $request->uri->path;

    try {

        ($handler, @params) = $self->routes->dispatcher($url);

        if ($handler ne '') {

            $class = $self->_init_handler($handler, $location);
            $response = $class->handler($self, ref($class), @params);

        } else {

            $handler = $self->config('default_handler');
            $class = $self->_init_handler($handler, $location);
            $response = $class->handler($self, ref($class), @params);

        }

    } catch {

        my $ex = $_;

        $self->_unexpected_exception($ex);
        $response = $self->response;

    };

    return $response;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    my $engine;
    my $configs;
    my $plugins;

    $self->{config} = $config;

    $self->_set_config_defaults();
    $configs = $self->config('configs');

    # init caching

    if (my $cache = $self->config('cache')) {

        $self->{cache} = $cache;

    } else {

        $self->{cache} = Scaffold::Cache::FastMmap->new(
           namespace => $configs->{cache_namespace},
       );

    }

    # init the lockmgr

    if (my $lockmgr = $self->config('lockmgr')) {

        $self->{lockmgr} = $lockmgr;

    } else {

        $self->{lockmgr} = Scaffold::Lockmgr::UnixMutex->new();

    }

    push(@{$self->{plugins}}, Scaffold::Cache::Manager->new());
    push(@{$self->{plugins}}, Scaffold::Stash::Manager->new());

    # init rendering

    if (my $render = $self->config('render')) {

        $self->{render} = $render;

    } else {

        $self->{render} = Scaffold::Render::Default->new();

    }

    # init session handling

    if (my $session = $self->config('session')) {

        $self->_init_plugin($session);

    } else {

        $self->_init_plugin('Scaffold::Session::Manager');

    }

    # init database handling

    if (my $database = $self->config('database')) {

        $self->{database} = $database;

    }

    # init authorization handling

    if (my $auth = $self->config('authorization')) {

        if (defined($auth->{authorize})) {

            $self->{authz} = $self->_init_module($auth->{authorize});

        }

        if (defined($auth->{authenticate})) {

            $self->_init_plugin($auth->{authenticate});

        }

    }

    # load the other plugins

    if ($plugins = $self->config('plugins')) {

        foreach my $plugin (@$plugins) {

            $self->_init_plugin($plugin);

        }

    }

    my $routes = $self->config('locations');
    $self->{routes} = Scaffold::Routes->new(routes => $routes);

    $engine = $self->config('engine');

    $self->{engine} = Scaffold::Engine->new(
        server => {
            module => $engine->{module},
            args => (defined($engine->{args}) ? $engine->{args} : {}),
        },
        request_handler => \&dispatch,
        scaffold => $self,
    );

    return $self;

}

sub _init_plugin {
    my ($self, $plugin) = @_;

    try {

        my $obj = init_module($plugin);
        push(@{$self->{plugins}}, $obj);

    } catch {
        
        my $ex = $_;

        $self->throw_msg(NOPLUGIN, 'noplugin', $plugin, $ex);

    };

}

sub _init_module {
    my ($self, $module) = @_;

    my $obj;

    try {

        $obj = init_module($module);

    } catch {

        my $ex = $_;

        $self->throw_msg(NOMODULE, 'nomodule', $module, $ex);

    };

    return $obj;

}

sub _init_handler {
    my ($self, $handler, $location) = @_;

    my $obj;

    try {

        if (defined($self->{config}->{handlers}->{$handler})) {

            $obj = $self->{config}->{handlers}->{$handler};

        } else {

            $obj = init_module($handler);

            $self->{config}->{handlers}->{$handler} = $obj;

        }

    } catch {

        my $ex = $_;

        $self->throw_msg(NOHANDLER, 'nohandler', $handler, $location, $ex->info);

    };

    return $obj;

}

sub _set_config_defaults {
    my ($self) = @_;

    if (! defined($self->{config}->{configs}->{app_rootp})) {

        $self->{config}->{configs}->{app_rootp} = '/';

    }

    if (! defined($self->{config}->{configs}->{doc_rootp})) {

        $self->{config}->{configs}->{doc_rootp} = 'html';

    }

    if (! defined($self->{config}->{configs}->{static_search})) {

        my $search_path = "html:html/static:html/templates";
        $self->{config}->{configs}->{static_search} = $search_path;

    }

    if (! defined($self->{config}->{configs}->{static_cached})) {

        $self->{config}->{configs}->{static_cached} = TRUE;

    }

    if (! defined($self->{config}->{configs}->{cache_namespace})) {

        $self->{config}->{configs}->{cache_namespace} = 'scaffold';

    }

    if (! defined($self->{config}->{configs}->{favicon})) {

        $self->{config}->{configs}->{favicon} = 'favicon.ico';

    }

    if (! defined($self->{config}->{default_handler})) {

        $self->{config}->{default_handler} = 'Scaffold::Handler::Default';

    }

}

sub _unexpected_exception {
    my ($self, $ex) = @_;

    my $text = qq(
        Unexpected exception caught<br />
        <span style='font-size: .8em'>
        Type: $ex->type<br />
        Info: $ex->info<br />
        </span>
    );

    my $page = $self->custom_error($self, 'Unexcpected Exception', $text);

    $self->response->status('500');
    $self->response->body($page);

}

1;

__END__

=head1 NAME

Scaffold::Server - The Scaffold web engine

=head1 SYNOPSIS

 app.psgi
 --------

 use lib 'lib';
 use lib '../lib';
 use Scaffold::Server;
 use Scaffold::Render::TT;

 my $psgi_handler;

 main: {

    my $server = Scaffold::Server->new(
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
                route   => qr{^/login/(.*)$},
                handler => 'Scaffold::Uaf::Login',
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
    );

    $psgi_hander = $server->engine->psgi_handler();

 }

Initializes and returns a handle for the psgi engine. Suitable for this command:

 # plackup -app app.psgi -s Standalone::Prefork

Which is a great way to develop and test your web application. By the way, 
the above configuration would run a complete static page site that needs 
authentication for access. 

=head1 DESCRIPTION

This module is the main entry point for an application built with Scaffold. 
It parses the configuration, loads the various components, makes the various 
connections for the CacheManager, the LockManager, initializes the 
SessionManager and will connect to the database of your choice.

=head1 METHODS

=over 4

=item dispatch

This method parses the URL and dispatches to the appropiate handler for request
handling. 

=back

=head1 SEE ALSO

 Scaffold
 Scaffold::Base
 Scaffold::Cache
 Scaffold::Cache::FastMmap
 Scaffold::Cache::Manager
 Scaffold::Cache::Memcached
 Scaffold::Class
 Scaffold::Constants
 Scaffold::Engine
 Scaffold::Handler
 Scaffold::Handler::Default
 Scaffold::Handler::Favicon
 Scaffold::Handler::Robots
 Scaffold::Handler::Static
 Scaffold::Lockmgr
 Scaffold::Lockmgr::KeyedMutex
 Scaffold::Lockmgr::UnixMutex
 Scaffold::Plugins
 Scaffold::Render
 Scaffold::Render::Default
 Scaffold::Render::TT
 Scaffold::Server
 Scaffold::Session::Manager
 Scaffold::Stash
 Scaffold::Stash::Controller
 Scaffold::Stash::Cookie
 Scaffold::Stash::View
 Scaffold::Uaf::Authenticate
 Scaffold::Uaf::AuthorizeFactory
 Scaffold::Uaf::Authorize
 Scaffold::Uaf::GrantAllRule
 Scaffold::Uaf::Login
 Scaffold::Uaf::Logout
 Scaffold::Uaf::Manager
 Scaffold::Uaf::Rule
 Scaffold::Uaf::User
 Scaffold::Utils

=head1 AUTHOR

Kevin L. Esteb, E<lt>kevin@kesteb.usE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
