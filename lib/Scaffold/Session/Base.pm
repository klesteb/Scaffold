package Scaffold::Session;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'id, user, address',
  mutators  => 'create, access, age',
  as_text   => '_to_string',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub has_info($) {
    my ($self) = @_;

    return (my $x = $self->user);

}

sub creation_age($) {
    my ($self, $now) = @_;

    return (($now or time()) - $self->create);

}

sub access_age($) {
    my ($self, $now) = @_;

    return (($now or time()) - $self->access);

}

sub access_time($$) {
    my ($self, $resolution) = @_;

    my $now = time();

    if (($now - $self->access) > $resolution) {

	$self->access($now);

    }

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub _to_string($) {
    my ($self) = @_;

    return sprintf("%s;%s;%s;%s;%s", 
	$self->id, $self->user, $self->address, $self->create, $self->access);

}

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    $self->{id}      = $self->config('-id');
    $self->{user}    = $self->config('-user');
    $self->{address} = $self->config('-address');
    $self->{create}  = $self->config('-create') || time();
    $self->{access}  = $self->config('-access') || time();

    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Session - The class for Sessions in Scaffold

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
