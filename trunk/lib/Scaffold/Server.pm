package Scaffold::Server;

use strict;
use warning;

our $VERSION = '0.01';

use HTTP::Engine;
use Scaffold::Render;
use HTTP::Engine::Response;
use Scaffold::Cache::Manager;
use Scaffold::Cache::FastMmap;
use Scaffold::Session::Manager;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'engine cache session render database plugins req res',
  filesystem => 'File',
  messages => {
      'nomod'  => "module not defined for %s",
      'noplug' => "plugin %s not initialized because: %s",
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub dispatch($$) {
    my ($self, $request) = @_;

    $self->{req} = $request;
    $self->{res} = HTTP::Engine::Response->new();

    my $locations = $self->config('-locations');

    my @path = (split( m|/|, $request->uri||'' ));

    while (@path) {

        $self->{config}->{location} = join('/', @path);

        if (defined $locations->{$self->{config}->{location}}) {

            my $mod = $locations->{$self->{config}->{location}}; 

            $self->throw_msg('scaffold.server.dispatch', 'nomod', $self->{config}->{location});
                unless $mod;

            eval "use $mod";
            if ( $@ ) { die $@; }

            return $mod->handler($self);

        }

        pop(@path);

    } # end while path

    $self->{config}->{location} = '/';
    my $mod = $locations->{ '/' }; 

    eval "use $mod" if $mod;
    if ( $@ ) { die $@; }

    return $mod->handler($self);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    my $engine;
    my $plugins;

    $self->{config} = $config;

    if (my $cache = $self->config('cache')) {

        $self->{cache} = $cache;

    } else {

        $self->{cache} = Scaffold::Cache::FastMmap->new();

    }

    if (my $render = $self->config('render')) {

        $self->{render} = $render;

    } else {

        $self->{render} = Scaffold::Render->new();

    }

    $engine = $self->config('engine');

    $self->{engine} = HTTP::Engine->new(
        interface => {
            module => $engine->{module},
            (defined($engine->{args}) ? args => $engine->{args), {}),
            handler => sub {
                $self->dispatch();
            }
        }
    );

    # load the default plugins

    push(@$self->plugins, Scaffold::Cache::Manager->new());
    push(@$self->plugins, Scaffold::Session::Manager->new());

    # load the specified plugins

    $plugins = $self->config('plugins');

    foreach my $plugin (@$plugins) {

        eval {

            my @path = split('::', $plugin);
            my $plug = File(@path);

            require $plug . '.pm';
            $plug->import();

            push(@$self->plugins, $plug->new());

        }; if (my $ex = $@) {

            $self->throw_msg('scaffold.server', 'noplug', $plugin, $@);

        }

    }

    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Server - A base class for Cache Management in Scaffold

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
