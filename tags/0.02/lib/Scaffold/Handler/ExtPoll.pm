package Scaffold::Handler::ExtPoll;

use strict;
use warnings;

our $VERSION = '0.01';

use DateTime;
use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler',
  codec   => 'JSON',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub do_default {
    my ($self) = @_;

    my $dt = DateTime->now(time_zone => 'local');
    my $status = {
        type => 'event',
        name => 'message',
        data => sprintf("Successfully polled at: %s %s", $dt->mdy, $dt->hms),
    };
  
    $self->stash->view->data(encode($satus));
    $self->stash->view->template_disabled(1);
    $self->stash->view->content_type('application/json');

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Handler::ExtPoll - A handler to for the Ext.direct poller

=head1 SYNOPSIS

 use Scaffold::Server;

 my $server = Scaffold::Server->new(
    configs => {
        doc_rootp => 'html',
    },
    locations => {
        '/'            => 'App::Main',
        '/robots.txt'  => 'Scaffold::Handler::Robots',
        '/favicon.ico' => 'Scaffold::Handler::Favicon',
        '/static'      => 'Scaffold::Handler::Static',
        '/poll'        => 'Scaffold::Handler::ExtPoll',
    },
 );

=head1 DESCRIPTION

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
