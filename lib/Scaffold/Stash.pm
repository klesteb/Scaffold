package Scaffold::Stash;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Stash::View;
use Scaffold::Stash::Controller;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'view controller cookies output',
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

    $self->{view}       = Scaffold::Stash::View->new();
    $self->{controller} = Scaffold::Stash::Controller->new();

    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Stash - The base class uri method dispatch

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
