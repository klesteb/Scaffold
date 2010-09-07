package Scaffold::Lockmgr::UnixMutex;

our $VERSION = '0.01';

use 5.8.8;
use Try::Tiny;
use IPC::Semaphore;
use IPC::SysV qw( IPC_CREAT S_IRWXU IPC_NOWAIT SEM_UNDO );

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Lockmgr',
  constants => 'TRUE FALSE',
  messages => {
      'nosemaphores' => 'unable to aquire a semaphore set: reason %s',
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub allocate {
    my ($self, $key) = @_;

    my $size = $self->config('nsems');

    if (! exists($self->{locks}->{$key})) {

        for (my $x = 0; $x < $size; $x++) {

            if ($self->{locks}->{available}[$x] == 1) {

                $self->{locks}->{available}[$x] = 0;
                $self->{locks}->{$key}->{semno} = $x;

                last;

            }

        }

    }

}

sub deallocate {
    my ($self, $key) = @_;

    my $semno;

    if (defined($key)) {

	if (exists($self->{locks}->{$key})) {

	    $semno = $self->{locks}->{$key}->{semno};
	    $self->{locks}->{available}[$semno] = 1;
	    delete $self->{locks}->{$key};

	}

    }

}

sub lock {
    my ($self, $key) = @_;

    my $semno;
    my $count = 0;
    my $stat = TRUE;

    if (exists($self->{locks}->{$key})) {

        $semno = $self->{locks}->{$key}->{semno};

        while (! $self->engine->op($semno, -1, IPC_NOWAIT | SEM_UNDO)) {

            $count++;

            if ($count < $self->limit) {

                sleep $self->timeout;

            } else {

                $stat = FALSE;
                last;

            }

        }

    } else {

        $stat = FALSE;

    }

    return $stat;

}

sub unlock {
    my ($self, $key) = @_;

    my $semno;

    if (exists($self->{locks}->{$key})) {

        $semno = $self->{locks}->{$key}->{semno};
        $self->engine->op($semno, 1, 0);

    }

}

sub try_lock {
    my ($self, $key) = @_;

    my $semno;
    my $stat = FALSE;

    if (exists($self->{locks}->{$key})) {

        $semno = $self->{locks}->{$key}->{semno};
        $stat = $self->engine->getncnt($semno) ? FALSE : TRUE;

    }

    return $stat;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    if (! defined($config->{nsems})) {

        if ($^O eq "aix") {

            $config->{nsems} = 250;

        } elsif ($^O eq 'linux') {

            $config->{nsems} = 250;

        } elsif ($^O eq 'bsd') {

            $config->{nsems} = 8;

        } else {

            $config->{nsems} = 16;

        }

    }

    if (! defined($config->{key})) {

        my $hash;
        my $name = 'scaffold';

        for (my $x = 0; $x < length($name); $x++) {

            $hash += ord(substr($name, $x, 1));

        }

        $config->{key} = $hash;

    }

    $self->{config}  = $config;
    $self->{owner}   = $$;
    $self->{limit}   = $config->{limit} || 10;
    $self->{timeout} = $config->{timeout} || 10;

    for (my $x = 0; $x < $config->{nsems}; $x++) {

        $self->{locks}->{available}[$x] = 1;

    }

    try {

        $self->{engine} = IPC::Semaphore->new(
            $config->{key},
            $config->{nsems},
            (S_IRWXU | IPC_CREAT)
        ) or die $!;

    } catch {

        my $ex = $_;

    	$self->throw_msg(
            'scaffold.lockmgr.unixmutex',
            'nosemaphores',
            $ex
        );

    };

    $self->engine->setval(0, $config->{nsems});

    return $self;

}

sub DESTROY {
    my $self = shift;

    if (defined($self->{engine})) {

	$self->engine->remove();

    }

}

1;

__END__

=head1 NAME

Scaffold::Lockmgr::UnixMutex - Use SysV semaphores for resource locking.

=head1 SYNOPSIS

 use Scaffold::Server;
 use Scaffold::Lockmgr::UnixMutex;

 my $psgi_handler;

 main: {

    my $server = Scaffold::Server->new(
        lockmgr => Scaffold::Lockmgr::UnixMutex->new(
            key     => 1234,
            nsems   => 32,
            timeout => 10,
            limit   => 10
        },
    );

    $psgi_hander = $server->engine->psgi_handler();

 }

=head1 DESCRIPTION

This implenments general purpose resource locking with SysV semaphores. 

=head1 CONFIGURATION

=over 4

=item key

This is a numeric key to identify the semaphore set. The default is a hash
of "scaffold".

=item nsems

The number of semaphores in the semaphore set. The default is dependent 
on platform. 

    linux - 250
    aix   - 250
    bsd   - 8
    other - 16

=item timeout

The number of seconds to sleep if the lock is not available. Default is 10
seconds.

=item limit

The number of attempts to try the lock. If the limit is passed an exception
is thrown. The default is 10.

=back

=head1 SEE ALSO

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
 Scaffold::Handler::Default
 Scaffold::Handler::Favicon
 Scaffold::Handler::Robots
 Scaffold::Handler::Static
 Scaffold::Lockmgr
 Scaffold::Lockmgr::KeyedMutex
 Scaffold::Lockmgr::UnixMutex
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

Copyright (C) 2010 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
