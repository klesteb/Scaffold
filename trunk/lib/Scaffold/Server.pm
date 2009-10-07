package Scaffold::Server;

use strict;
use warning;

our $VERSION = '0.01';

use HTTP::Engine;
use Scaffold::Render;
use HTTP::Engine::Response;
use Scaffold::Cache::FastMmap;
use Scaffold::Session::Manager;
use Scaffold::Session::Store::Cache;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'engine cache session render database req res',
  messages => {
      'nomod' => 'module not defined for %s',
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

    $self->{config}  = $config;

    if (my $cache = $self->config('-cache')) {

	$self->{cache} = $cache;

    } else {

	$self->{cache} = Scaffold::Cache::FastMmap->new();

    }

    if (my $session = $self->config('-session')) {

	$self->{session} = $session;

    } else {

	$self->{session} = Scaffold::Session::Manager->new(
	    -session  => Scaffold::Session::Base->new(),
	    -storage  => Scaffols::Session::Store::Cache->new(),
	    -scaffold => $self,
	);

    }

    if (my $render = $self->config('-render')) {

	$self->{render} = $render;

    } else {

	$self->{render} = Scaffold::Render->new();

    }

    $self->{engine} = HTTP::Engine->new(
	interface => {
	    module => $self->config('-engine'),
	    handler => sub {
		$self->dispatch();
	    }
	}
    );

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
