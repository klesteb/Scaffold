package Scaffold::Server;

use strict;
use warning;

our $VERSION = '0.01';

use HTTP::Engine;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'engine cache session database',
  messages => {
      'nomod' => 'module not defined for %s',
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub dispatch($$) {
    my ($self, $request) = @_;

    my $response = HTTP::Engine::Response->new();
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

            return $mod->handler($self, $request, $response);

        }

        pop(@path);

    } # end while path

    $self->{config}->{location} = '/';
    my $mod = $locations->{ '/' }; 

    eval "use $mod" if $mod;
    if ( $@ ) { die $@; }

    return $mod->handler($self, $request, $response);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config}  = $config;
    $self->{cache}   = $self->config('-cache');
    $self->{session} = $self->config('-session');
    
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
