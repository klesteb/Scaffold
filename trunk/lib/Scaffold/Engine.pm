package Scaffold::Engine;

use strict;
use warnings;

our $VERSION = '0.01';

use Plack::Loader;
use Plack::Builder;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'server request_handler request_class middlewares scaffold',
  messages => {
      'norequest' => "request_handler is required",
      'nomodule'  => "{server}->{module} is required",
      'noserver'  => "interace is required",
  },
  constant => {
      NOREQUEST => 'scaffold.engine.norequest',
      NOMODULE  => 'scaffold.engine.nomodule',
      NOSERVER  => 'scaffold.engine.noserver',
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub run($) {
    my ($self) = @_;

    my $server_instance;
    my $request_handler;

    $self->throw_msg(NOSERVER, 'noserver') unless $self->{server};
    $self->throw_msg(NOMODULE, 'nomodule') unless $self->{server}->{module};

    $server_instance = $self->_build_server_instance(
        $self->{server}->{module},
        $self->{server}->{args}
    );

    $request_handler = $self->psgi_handler;
    $server_instance->run($request_handler);

}

sub psgi_handler {
    shift->_build_request_handler;
}

sub build_request($$) {
    my ($self, $env) = @_;

    my $response = $self->{request_class}->new($env);
    
    return $response;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    $self->throw_msg(NOREQUEST, 'norequest') unless $config->{request_handler};

    $self->{server} = $config->{server};
    $self->{scaffold} = $config->{scaffold};
    $self->{middlewares} = $config->{middlewares} || [];
    $self->{request_handler} = $config->{request_handler};
    $self->{request_class} = $config->{request_class} || 'Plack::Request';

    Scaffold::Engine::Util::load_class($self->{request_class});

    return $self;

}

sub _build_server_instance($$$) {
    my ($class, $server, $args) = @_;

    Plack::Loader->load($server, %$args);

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
        my $scaffold = $self->scaffold;
        my $req = $self->build_request($env);
        my $res = $self->{request_handler}->($scaffold, $req);
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

package Scaffold::Engine::Util;

sub load_class($$) {
    my ($class, $prefix) = @_;

    if ( $class !~ s/^\+// && $prefix ) {
        $class = "$prefix\::$class";
    }

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm";    ## no critic

    return $class;

}

1;

__END__

=head1 NAME

Scaffold::Engine - The Scaffold interface to psgi

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
