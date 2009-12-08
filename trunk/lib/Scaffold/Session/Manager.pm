package Scaffold::Session::Manager;

use strict;
use warnings;

our $VERSION = '0.01';

use HTTP::Session;
use Data::Random qw(:all);
use HTTP::Session::State::Cookie;
use Scaffold::Session::Store::Cache;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Plugins',
  constants => 'SESSION_ID :plugins',
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub pre_action($$) {
    my ($self, $sobj) = @_;

    my ($user, $address, $create ,$access, $random, $ident);

    my $session = HTTP::Session->new(
        store => Scaffold::Session::Store::Cache->new(
            cache => $sobj->scaffold->cache,
        ),
        state => HTTP::Session::State::Cookie->new(
            name => SESSION_ID
        ),
        request => $sobj->scaffold->request
    );

    $random = rand_chars(set => 'all', min => 5, max => 10);

    $user    = $session->get('user');
    $address = $session->get('address');
    $create  = $session->get('create');
    $access  = $session->get('access');
    $ident   = $session->get('ident');

    $session->set('user', $sobj->scaffold->request->user) if (not $user);
    $session->set('address', $sobj->scaffold->request->address) if (not $address);
    $session->set('create', time()) if (not $create);
    $session->set('access', time()) if (not $access);
    $session->set('ident', $random) if (not $ident);

    $sobj->scaffold->session($session);

    return PLUGIN_NEXT;

}

sub post_render($$) {
    my ($self, $sobj) = @_;

    my $response = $sobj->scaffold->response;
    my $session = $sobj->scaffold->session;

    $session->set('access', time());
    $session->response_filter($response);

    $session->finalize();          # must be the last thing done!!

    return PLUGIN_NEXT;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::SessionManager - The class for Sessions in Scaffold

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
