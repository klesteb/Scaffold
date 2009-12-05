package Scaffold::Uaf::Logout;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler',
;

# -----------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------

sub do_main {
    my ($self) = @_;

    my $title = $self->scaffold->config('configs')->{uaf_title} || 'Logging out';
    my $wrapper = $self->scaffold->config('configs')->{uaf_wrapper} || 'nowrapper.tt';
    my $template = $self->scaffolg->config('configs')->{uaf_template} || 'uaf_logout.tt';

    $self->stash->view->title($title);
    $self->stash->view->template_wrapper($wrapper);
    $self->stash->view->template($template);

    $self->scaffold->authn->invalidate();
    
}

# -----------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------

1;

=head1 NAME

Events::Uaf::Logout - A handler for logout actions

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
