package Scaffold::Server;

use strict;
use warnings;

our $VERSION = '0.01';

use Plack::Response;
use Scaffold::Engine;
use Scaffold::Cache::Manager;
use Scaffold::Render::Default;
use Scaffold::Cache::FastMmap;
use Scaffold::Session::Manager;
use Scaffold::Lockmgr::KeyedMutex;

use Scaffold::Class
  version    => $VERSION,
  base       => 'Scaffold::Base',
  accessors  => 'authz authn engine cache render database plugins request response lockmgr',
  mutators   => 'session',
  filesystem => 'File',
  constants  => 'TRUE FALSE',
  messages => {
      'nomodule'  => "handler not defined for %s",
      'noplugin'  => "plugin %s not initialized, because: %s",
      'nohandler' => "handler %s for location %s was not loaded, because: %s",
  },
  constant => {
      NOMODULE  => 'scaffold.server.nomodule',
      NOPLUGIN  => 'scaffold.server.noplugin',
      NOHANDLER => 'scaffold.server.nohandler',
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub dispatch($$) {
    my ($self, $request) = @_;

    $self->{request} = $request;
    $self->{response} = Plack::Response->new();

    my $class;
    my $response;
    my $location;
    my $url = $request->uri;
    my $uri = lc($url->path);
    my $locations = $self->config('locations');
    my @path = (split( m|/|, $uri ||'' ));

    while (@path) {

        $location = join('/', @path);

        if (defined $locations->{$location}) {

            if (my $mod = $locations->{$location}) {

                $class = $self->_init_handler($mod, $location);
                $response = $class->handler($self, $location, ref($class));
                return $response;

            } else {

                $self->throw_msg(NOMODULE, 'nomodule', $location);

            }

        }

        pop(@path);

    }

    $location = '/';
    my $mod = $locations->{$location}; 
    $class = $self->_init_handler($mod, $location);
    $response = $class->handler($self, $location, ref($class));

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

    push(@{$self->{plugins}}, Scaffold::Cache::Manager->new());

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

    # init the lockmgr

    if (my $lockmgr = $self->config('lockmgr')) {

        $self->{lockmgr} = $lockmgr;

    } else {

        $self->{lockmgr} = Scaffold::Lockmgr::KeyedMutex->new();

    }

    # init database handling

    if (my $database = $self->config('database')) {

        $self->{database} = $database;

    }

    # load the other plugins

    if ($plugins = $self->config('plugins')) {

        foreach my $plugin (@$plugins) {

            $self->_init_plugin($plugin);

        }

    }

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

sub _init_plugin($$) {
    my ($self, $plugin) = @_;

    eval {

        my @parts = split("::", $plugin);
        my $filename = File(@parts);

        require $filename . '.pm';
        $plugin->import();
        my $obj = $plugin->new();

        push(@{$self->{plugins}}, $obj);

    }; if (my $ex = $@) {

        $self->throw_msg(NOPLUGIN, 'noplugin', $plugin, $@);

    }

}

sub _init_handler($$$) {
    my ($self, $handler, $location) = @_;

    my $obj;

    eval {

        if (defined($self->{config}->{handlers}->{$location})) {

            $obj = $self->{config}->{handlers}->{$location}->{handler};

        } else {

            my @parts = split("::", $handler);
            my $filename = File(@parts);

            require $filename . '.pm';
            $handler->import();
            $obj = $handler->new();

            $self->{config}->{handlers}->{location} = $location;
            $self->{config}->{handlers}->{$location}->{handler} = $obj;

        }

    }; if (my $ex = $@) {

        $self->throw_msg(NOHANDLER, 'nohandler', $handler, $location, $@);

    }

    return $obj;

}

sub _set_config_defaults($) {
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

    if (! defined($self->{config}->{configs}->{cache_static})) {

        $self->{config}->{configs}->{cache_static} = TRUE;

    }

    if (! defined($self->{config}->{configs}->{cache_namespace})) {

        $self->{config}->{configs}->{cache_namespace} = 'scaffold';

    }

    if (! defined($self->{config}->{configs}->{favicon})) {

        $self->{config}->{configs}->{favicon} = 'favicon.ico';

    }

}

1;

__END__

=head1 NAME

Scaffold::Server - The Scaffold web engine

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ACCESSORS

=over 4

=back

=head1 SEE ALSO

 Scaffold::Base
 Scaffold::Class

=head1 AUTHOR

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
