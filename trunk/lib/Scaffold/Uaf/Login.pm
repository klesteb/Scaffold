package Scaffold::Uaf::Login;

use strict;
use warnings;

our $VERSION = '0.01';

use DateTime;
use Digest::MD5;
use Digest::HMAC;

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler',
  codecs  => 'JSON',
  mixin   => 'Scaffold::Uaf::Authenticate',
;

# -----------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------

sub do_main {
    my ($self) = @_;

warn "Login/do_main()\n";

    $self->uaf_init();
    
    my $title = $self->uaf_login_title;
    my $wrapper = $self->uaf_login_wrapper;
    my $template = $self->uaf_login_template;

    $self->stash->view->title($title);
    $self->stash->view->template_wrapper($wrapper);
    $self->stash->view->template($template);

}

sub do_denied {
    my ($self) = @_;

    $self->uaf_init();

    my $title = $self->uaf_denied_title;
    my $wrapper = $self->uaf_denied_wrapper;
    my $template = $self->uaf_denied_template;

    $self->stash->view->title($title);
    $self->stash->view->template_wrapper($wrapper);
    $self->stash->view->template($template);

}

sub do_validate {
    my ($self) = @_;

warn "Login/do_validate()\n";
    $self->uaf_init();

    my $login_rootp;
    my $denied_rootp;
    my $user = undef;
    my $limit = $self->uaf_limit;
    my $params = $self->scaffold->request->parameters();
    my $count = $self->scaffold->session->get('uaf_login_attempts');
    my $app_rootp = $self->scaffold->config('configs')->{app_rootp};

    $count++;
    $self->scaffold->session->set('uaf_login_attempts', $count);
    $login_rootp = $self->uaf_login_rootp;
    $denied_rootp = $self->uaf_denied_rootp;

    $user = $self->uaf_validate(
        $params->{username}, 
        $params->{password}
    );

    if (defined($user)) {

        $self->scaffold->session->set('uaf_user', $user);

        if ($count > $limit) {

            $self->redirect($denied_rootp);
            return;

        }

        $self->scaffold->session->set('uaf_login_attempts', 0);
        $self->uaf_set_token($user);
        $self->redirect($app_rootp);

    } else {

        $self->redirect($login_rootp); 

    }

}

# -----------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------

1;

=head1 NAME

Scaffold::Uaf::Login - A controller in the Monitor application

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item do_main

=back

=head1 DEPENDENCIES

=head1 AUTHOR

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
