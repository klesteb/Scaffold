package Scaffold::Session::Store::Cache;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Class::Accessor::Fast';
use Scaffold::Constants 'LOCK';

__PACKAGE__->mk_ro_accessors(qw/cache expires/);

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub new {
    my $class = shift;
    my %args = ref($_[0]) ? %{$_[0]} : @_;

    # check required parameters

    for (qw/cache/) {

        Carp::croak "missing parameter $_" unless $args{$_};

    }

    unless (ref $args{cache} && index(ref($args{cache}), 'Cache') >= 0) {

        Carp::croak "cache requires instance of Scaffold::Cache::Memcached or Scaffold::Cache::FastMmap";

    }

    bless {%args}, $class;

}

sub select {
    my ($self, $session_id) = @_;

    my $data;

    $data = $self->cache->get($session_id);

    return $data;

}

sub insert {
    my ($self, $session_id, $data) = @_;

    $self->cache->set($session_id, $data);

}

sub update {
    my ($self, $session_id, $data) = @_;

    $self->cache->update($session_id, $data);

}

sub delete {
    my ($self, $session_id) = @_;

    $self->cache->delete($session_id);

}

sub cleanup { Carp::croak "This storage doesn't support cleanup" }

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Session::Store::Cache - Use Scaffold's internal caching 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ACCESSORS

=over 4

=back

=head1 SEE ALSO

 HTTP::Session

=head1 AUTHOR

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
