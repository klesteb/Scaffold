package Scaffold::Engine;

use strict;
use warnings;

our $VERSION = '0.01';

use Plack::Loader;
use Plack::Builder;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'interface request_handler request_class middlewares',
  messages => {
      'norequest'   => "request_handler is required",
      'nomodule'    => "{interface}->{module} is required",
      'nointerface' => "interace is required",
  },
  constant => {
      NOREQUEST   => 'scaffold.engine.norequest',
      NOMODULE    => 'scaffold.engine.nomodule',
      NOINTERFACE => 'scaffold.engine.nointerface',
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub run($) {
    my ($self) = @_;

    my $server_instance;
    my $request_handler;

    $self->throw_msg(NOSERVER, 'nointerface') unless $self->{interface};
    $self->throw_msg(NOMODULE, 'nomodule') unless $self->{interface}->{module};

    $server_instance = $self->_build_server_instance(
        $self->{interface}->{module},
        $self->{interface}->{args}
    );

    $request_handler = $self->psgi_handler;
    $server_instance->run($request_handler);

}

sub psgi_handler {
    shift->_build_request_handler;
}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    $self->throw_msg(NOREQUEST, 'norequest') unless $config->{request_handler};

    $self->{interface} = $config->{interface};
    $self->{middlewares} = $config->{middlewares} || [];
    $self->{request_handler} = $config->{request_handler};
    $self->{request_class} = $config->{request_class} || 'Plack::Request'

    return $self;

}

sub _build_server_instance($$$) {
    my ($class, $server, $args) = @_;

    Plack::Loader->load($server, %args);

}

sub _build_request_handler($) {
    my ($self) = @_;

    my $app = $self->_build_app;

    $self->_wrap_with_middlewares($app);

}

sub _build_app($) {
    my ($self) = @_;

    return sub {
        my $env = shift;
        my $req = $self->build_request($env);
        my $res = $self->{request_handler}->($req);
        $res->finalize;
    };
    
}

sub _wrap_with_middlewares($$) {
    my ($self, $request_handler) = @_;

    my $builder = Plack::Builder->new;

    for my $middleware ( @{ $self->{middlewares} } ) {

        $builder->add_middleware( $middleware->{module},
            %{ $middleware->{opts} || {} } );

    }

    $builder->to_app($request_handler);

}

1;

__END__

=head1 NAME

Scaffold::Engine - The Scaffold web engine interface to psgi

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
