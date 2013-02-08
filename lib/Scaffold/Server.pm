package Scaffold::Server;

our $VERSION = '0.04';

use Try::Tiny;
use Set::Light;
use Plack::Response;
use Scaffold::Engine;
use Scaffold::Routes;
use Badger::Class::Methods;
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
  filesystem => 'File Path',
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
    my $path = $request->path_info;
    
    try {

        my ($handler, @params) = $self->routes->dispatcher($path);

        if ($handler ne '') {

            $class = $self->_init_handler($handler, $path);
            $response = $class->handler(ref($class), @params);

        } else {

            $handler = $self->config('default_handler');
            $class = $self->_init_handler($handler, $path);
            $response = $class->handler(ref($class), @params);

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
    my $set = Set::Light->new(qw/authz engine cache render database plugins request response lockmgr routes session user authorization locations configs/);
    my @accessors = keys(%$config);

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

    $self->_init_plugin('Scaffold::Cache::Manager');
    $self->_init_plugin('Scaffold::Stash::Manager');

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

    # build dynamic accessors for other config items

    foreach my $accessor (@accessors) {

        next if ($set->has($accessor));

        $self->{$accessor} = $self->config($accessor);
        Badger::Class::Methods->accessors(__PACKAGE__, $accessor);

    }

    # map the routes to handlers

    my $routes = $self->config('locations');
    $self->{routes} = Scaffold::Routes->new(routes => $routes);

    # off to the races we go

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

        my $obj = init_module($plugin, $self);
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

        $obj = init_module($module, $self);

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

            $obj = init_module($handler, $self);

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

    my $text;
    my $ref = ref($ex);

    if ($ref && $ex->isa('Scaffold::Exception')) {

        $text = qq(
            <p>Unexpected exception caught</p>
            <table>
              <tr>
                <td>Type:</td>
                <td>$ex->type</td>
              </tr>
              <tr>
                <td>Info:</td>
                <td>$ex->info</td>
              </tr>
            </table>
        );

    } else {

        my $e = sprintf("%s", $ex);
        $text = qq(
            <p>Unexpected exception caught</p>
            <table>
              <tr>
                <td>Message:</td>
                <td>$e</td>
              </tr>
            </table>
        );

    }

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
 use Scaffold::Server;

 my $psgi_handler;

 main: {

    my $server = Scaffold::Server->new(
        locations => [
            {
                route   => qr{^/robots.txt$},
                handler => 'Scaffold::Handler::Robots',
            },{
                route   => qr{^/favicon.ico$},
                handler => 'Scaffold::Handler::Favicon',
            },{
                route   => qr{^/login/(.*)$},
                handler => 'Scaffold::Uaf::Login',
            },{
                route   => qr{^/logout$},
                handler => 'Scaffold::Uaf::Logout',
            },{
                route   => qr{^/(.*)$},
                handler => 'Scaffold::Handler::Static',
            }
        ],
        authorization => {
            authenticate => 'Scaffold::Uaf::Manager',
            authorize    => 'Scaffold::Uaf::AuthorizeFactory',
        }
    );

    $psgi_hander = $server->engine->psgi_handler();

 }

Initializes and returns a handle for the psgi engine. Suitable for this command:

 # plackup app.psgi

Which is a great way to develop and test your web application. By the way, 
the above configuration would run a complete static page site that needs 
authentication for access. 

=head1 DESCRIPTION

This module is the main entry point for an application built with Scaffold. 
It parses the configuration, loads the various components, makes the various 
connections for the CacheManager, the LockManager, initializes the 
SessionManager and stores the connection to the database of your choice.

=head1 CONFIGURATION

The configuration has specific items that it requires. If they are not
present, reasonable defaults are used. They can be accessed from the
Scaffold object. The accessors is usually the same as the configuration
item, unless noted otherwise. The following configuration stanzas are used:

=head2 cache

This defines the caching system to use. This system must use the api defined
in L<Scaffold::Cache|Scaffold::Cache>. The default is L<Scaffold::Cache::FastMmap|Scaffold::Cache::FastMmap> 
with the default name space.

=head2 lockmgr

This defines the lock manger to use. This lock manager must use the api defined
in L<Scaffold::Lockmgr|Scaffold::Lockmgr>. The default is L<Scaffold::Lockmgr::UnixMutex|Scaffold::Lockmgr::UnixMutex>
with reasonable defaults. 

=head2 render

This defines the render to use when sending output. The render must use the api
defined in L<Scaffold::Render|Scaffold::Render>. The default render is L<Scaffold::Render::Default|Scaffold::Render::Default>.

=head2 session

The session manager runs as a plugin, this allows you to define a different 
one. It must use the api for plugins. The default is 
L<Scaffold::Session::Manager|Scaffold::Session::Manager>.

=head2 database

This establishes a connection to the database. You may have multiple 
connections defined. They can be access using database->{item}.

=head2 authorization

This allowes you to set up a authorization scheme. It has two sub categories.
They are "authorize" and "authenticate". Authenticate runs as a plugin
and must follow the plugin api. Authorize can be accessed with the "authz"
accessor on the Scaffold object.

=head2 plugins

These are additional plugins that you may want to run. They must follow the
plugin api.

=head2 locations

This provides routes for your application. Routes are used to direct requests
to specific handlers. Locations are an array of hash values. The hash values
have two items: "route" and "handler". Route is a regex to match urls against 
and handler is the code to handle that url.

=head2 engine

This allows you to configure the underlaying plack interface.

=head2 configs

This stanza allows you to configure specific items. You can place anything 
here to is be accessed later. The is done by:

 $self->scaffold->config('configs')->{item};

The following defaults are provided.

=over 4

=item B<app_rootp>

This is the base url for the application. It defaults to "/".

=item B<doc_rootp>

This is where you html resides. It is a directory name, it defaults to 'html'.

=item B<static_search>

This is used by Scaffold::Handler::Static as a search path. It is colon
delimted list of directories. It defaults to "html:html/static:html/templates".

=item B<static_cached>

This indicates wither to cache static items. It defaults to true.

=item B<cache_namespace>

This is the name space to use when caching. It defaults to "scaffold".

=item B<favicon>

This is used by L<Scaffold::Handler::Favicon|Scaffold::Handler::Favicon>. 
It defaults to "favicon.ico".

=item B<default_handler>

The default handler to invoke when no routes are matched. It defaults 
to L<Scaffold::Handler::Default|Scaffold::Handler::Default>.

=back

=head2 Other Items

Addtional configuration items can be used. For example, if you want to add 
access to a job queue such as Gearman you could do the following:

    my $server = Scaffold::Server->new(
         locations => [
         ],
         gearman => XAS::Lib::Gearman::Client->new(),
         database => {
         }
    );

Later in you application you can access Gearman with the following syntax:

    $self->scaffold->gearman->process();

Where the process() method does whatever. 

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
