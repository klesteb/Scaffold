package Scaffold::Stash::Cookies;

use strict;
use warnings;

our $VERSION = '0.01';

use CGI::Simple::Cookie;

use Scaffold::Class
  version  => $VERSION,
  base     => 'Scaffold::Base',
  accessors => 'cookies',
  constants => 'HASH',
  messages => {
      badformat => "Attribute (cookies) does not pass the type constraint because: Vaidation failed for 'HASHREF' reference",
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub cookie {
    my ($self, $name) = @_;

    return keys %{ $self->cookies } if (! defined($name));

    if (exists($self->cookies->{$name})) {

        return $self->cookies->{$name};

    }

    return undef;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    if (defined $config->{cookies}) {

        unless (ref($config->{cookies}) eq HASH) {

            $self->throw_msg('scaffold.stash.cookies', 'badformat'); 

        }

        while ( my ($key, $value) = each(%{$config->{cookies}})) {

            $self->{cookies}->{$key} = CGI::Simple::Cookie->new(
                -name  => $key,
                -value => $value
            );

        }

    }

    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Stash::Cookies - A cookied handler for Scaffold

=head1 SYNOPSIS

 $self->stash->cookies->new( 
     cookies => $self->scaffold->request->cookies
 );

=head1 DESCRIPTION

This a handler for cookies within Scaffold.

=head1 ACCESSORS

=over 4

=item cookies

Returns a refrence to a hash containing all of the cookies.

 my %cookies = $self->stash->cookies->cookies();

=item cookie

Returns the named cookie all or an array of CGI::Simple::Cookies objects.

 my $cookie = $self->stash->cookies->cookie('name');
 my @cookies = $self->stash->cookies->cookie();

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
