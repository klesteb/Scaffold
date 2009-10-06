package Scaffold::SessionManager;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'storage session',
  constants => {
      ACCESS_TIME_RESOLUTION => 1,
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;
    
    $self->{session} = $self->config('-session');
    $self->{storeage} = $self->config('-storage');
    
    return $self;

}

1;

__END__

=head1 NAME

Scaffold::SessionManager - The class for Sessions in Scaffold

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ACCESSORS

=over 4

=back

=head1 SEE ALSO

=head1 AUTHOR

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
