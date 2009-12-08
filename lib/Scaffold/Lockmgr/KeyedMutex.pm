package Scaffold::Lockmgr::KeyedMutex;

use strict;
use warnings;

our $VERSION = '0.01';

use KeyedMutex;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Lockmgr',
  constants => 'TRUE FALSE',
  accessors => 'engine',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub lock($$) {
    my ($self, $key) = @_;

    my $stat = FALSE;

    if ($self->engine->lock($key)) {

        $stat = TRUE;

    }

    return $stat;

}

sub unlock($$) {
    my ($self, $key) = @_;

    return $self->engine->release($key);

}

sub locked($$) {
    my ($self, $key) = @_;

    my $stat = FALSE;

    if ($self->engine->locked($key)) {

        $stat = TRUE;

    }

    return $stat;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    if (! defined($config->{port})) {

        $config->{port} = '9506';

    }

    if (! defined($config->{address})) {

        $config->{address} = '127.0.0.1';

    }

    $self->{config} = $config;

    $self->{engine} = KeyedMutex->new(
        {
            sock => $config->{address} . ':' . $config->{port},
        }
    );

    return $self;

}

1;

  __END__

=head1 NAME

Scaffold::Lockmgr::KeyedMutex - Use KeyedMutex as the backend.

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
