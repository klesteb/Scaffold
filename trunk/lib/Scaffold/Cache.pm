package Scaffold::Cache;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version  => $VERSION,
  base     => 'Scaffold::Base',
  mutators => 'handle namespace expires',
  constant => 'TRUE FALSE LOCK',
  messages => {
      'noload' => 'unable to load module; reason: %s',
  },
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub get($$) {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->get($skey);

}

sub set($$$) {
    my ($self, $key, $value) = @_;

    my $namespace = $self->namespace;
    my $expires = $self->expires;
    my $skey = $namespace . ':' . $key;

    return $self->handle->set($skey, $value, $expires);

}

sub delete($$) {
    my ($self, $key) = @_;

    my $namespace = $self->namespace;
    my $skey = $namespace . ':' . $key;

    return $self->handle->remove($skey);

}

sub update($$$) {
    my ($self, $key, $value) = @_;
    
}
    
sub clear($) {
    my ($self) = @_;

}

sub purge($) {
    my ($self} = @_;

}

sub incr($$) {
    my ($self, $key) = @_;
    

}

sub decr($$) {
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
