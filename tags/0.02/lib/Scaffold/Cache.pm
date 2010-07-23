package Scaffold::Cache;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version  => $VERSION,
  base     => 'Scaffold::Base',
  mutators => 'handle namespace expires',
  constant => 'TRUE FALSE',
  messages => {
      'noload' => 'unable to load module; reason: %s',
  },
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub get {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->get($skey);

}

sub set {
    my ($self, $key, $value) = @_;

    my $namespace = $self->namespace;
    my $expires = $self->expires;
    my $skey = $namespace . ':' . $key;

    return $self->handle->set($skey, $value, $expires);

}

sub delete {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->remove($skey);

}

sub update {
    my ($self, $key, $value) = @_;
    
}
    
sub clear {
    my ($self) = @_;

}

sub purge {
    my ($self) = @_;

}

sub incr {
    my ($self, $key) = @_;
    

}

sub decr {
    my ($self, $key) = @_;
    
}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Cache - A base class for Cache Management in Scaffold

=head1 SYNOPSIS

 my $server = Scaffold::Server->new(
     cache => Scaffold::Cache::FastMmap->new(
        namespace => 'scaffold',
    ),
 );

=head1 DESCRIPTION

The Scaffold environment uses caching by default. If no "cache" engine is 
defined, it will use Scaffold::Cache::FastMmap with reasonable, built in 
defaults. The caching subsystem is used by several of the Scaffold modules. 
This is done for performance reasons. i.e. it is usaully faster to load stuff 
from cache then to read it from disk.

Scaffold provides two caching engines, they are Scaffold::Cache::FastMmap and
Scaffold::Cache::Memcached.

Since these caching systems use a flat, shared environment, with key, 
value pairs for data storarge and retrieval, a "namespace" is defined to help
differated the "key" from other similar keys. This name space can be used to
define a flat naming scheme or even a hirearchal scheme, the choice is yours.
The "namespace" is prepended to the "key", so a key of "junk" would be 
presented to the caching system as "scaffold:junk".

=head1 METHODS

=over 4

=item get

This method will retrieve the "value" associated with "key".

 $value = $self->scaffold->cache->get('junk');

=item set

This method will store the "value" associated with "key".

 $self->scaffold->cache->set('junk', $value);

=item delete

This method will delete the "key" from the caching system.

 $self->scaffold->cache->delete('junk');

=item update

This method will update the "value" associated with "key". Most of the 
caching systems do this in a "atomic" fashion.

 $self->scaffold->cache->update('junk', $newvalue);

=item clear

This method will clear all items from the cache. Use with care.

 $self->scaffold->cache->clear();

=item purge

This method will purge expired items out of the cache. 

 $self->scaffold->cache->purge();

=item namespace

This method will get/set the current namespace for cache operations.

 $namespace = $self->scaffold->cache->namespace;
 $self->scaffold->cache->namespace($namespace);

=back

=head1 SEE ALSO

 Cache::FastMmap
 Cache::Memcached

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
