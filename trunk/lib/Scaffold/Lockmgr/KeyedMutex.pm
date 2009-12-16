package Scaffold::Lockmgr::KeyedMutex;

use strict;
use warnings;

our $VERSION = '0.01';

use KeyedMutex;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Lockmgr',
  constants => 'TRUE FALSE',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub lock {
    my ($self, $key) = @_;

    my $stat = TRUE;
    my $count = 0;

    while (! $self->engine->lock($key)) {

        $count++;

        if ($count < $self->limit) {

            sleep $self->timeout;

        } else {

            $stat = FALSE;
            last;

        }

    }

    return $stat;

}

sub unlock {
    my ($self, $key) = @_;

    return $self->engine->release($key);

}

sub try_lock {
    my ($self, $key) = @_;

    my $stat = TRUE;
    my $count = 0;

    while ($self->engine->locked($key)) {

        $count++;

        if ($count < $self->limit) {

            sleep $self->timeout;

        } else {

            $stat = FALSE;
            last;

        }

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

    $self->{config}  = $config;
    $self->{limit}   = $config->{limit} || 10;
    $self->{timeout} = $config->{timeout} || 10;

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

=head1 DESCRIPTION

This implenments general purpose locking using KeyedMutex. KeyedMutex is a 
distributed locking daemon with a perl interface module. 

=head1 SEE ALSO

 KeyedMutex

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
 Scaffold::Handler::Favicon
 Scaffold::Handler::Robots
 Scaffold::Handler::Static
 Scaffold::Lockmgr
 Scaffold::Lockmgr::KeyedMutex
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

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
