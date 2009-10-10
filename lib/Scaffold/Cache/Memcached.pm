package Scaffold::Cache::Memcached;

use strict;
use warnings;

our $VERSION = '0.01';

use Cache::Memcached;

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Cache',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub update($$$) {
    my ($self, $key, $value) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->replace($skey, $value);

}

sub clear($) {

    return $self->handle->flush_all();

}

sub incr($$) {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->incr($skey);

}

sub decr($$) {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->decr($skey);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config}    = $config;
    $self->{namespace} = $self->config('namespace');
    $self->{expires}   = $self->config('expires') || '3600';

    my $rehash   = $self->config('rehash') || 'no';
    my $servers  = $self->config('servers') || '127.0.0.1:11211';
    my $compress = $self->config('compress_threshold') || '1000';

    eval {

        $self->{handle} = Cache::Memcached->new({servers => [$servers]});
        $self->{handle}->set_compress_threshold($compress);
        $self->{handle}->enable_compres(1);
        $self->{handle}->set_norehash() if ($rehash =~ m/no/i);

    }; if (my $ex = $@) {

        $self->throw_msg('scaffold.cache.memcached', 'noload', $@);

    }
    
    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Cache::Memcached - Caching is based on memcached.

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
