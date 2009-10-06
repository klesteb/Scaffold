package Scaffold::Cache::FastMmap;

use strict;
use warnings;

our $VERSION = '0.01';

use Cache::FastMmap;

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Cache',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub purge($) {
    my ($self) = @_;

    return $self->handle->purge();

}

sub clear($) {

    return $self->handle->clear();

}

sub lock($) {
    my ($self) = @_;

    my $namespace = $self->namespace;
    my $lock = $namespace . ':' . LOCK;

    $self->handle->get_and_set($lock, 1);

}

sub unlock($) {
    my ($self) = @_;

    my $namespace = $self->namespace;
    my $lock = $namespace . ':' . LOCK;

    $self->handle->get_and_set($lock, 0);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{namespace} = "";
    $self->{config}  = $config;
    $self->{expires} = $self->config('-expires') || '1h';

    my $num_pages  = $self->config('-pages') || '256';
    my $page_size  = $self->config('-pagesize') || '256k';
    my $share_file = $self->config('-filename') || '/tmp/scaffold.cache';

    eval {

        $self->{handle} = Cache::FastMmap->new(
            num_pages      => $num_pages,
            page_size      => $page_size,
            expire_time    => $expire_time,
            share_file     => $share_file,
            compress       => 1
            unlink_on_exit => 0,
        );

    }; if (my $ex = $@) {

        $self->throw_msg('scaffold.cache.fastmmap', 'noload', $@);

    }

}

1;

__END__

=head1 NAME

Scaffold::Cache::FastMmap - Caching is based on fastmmap.

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
