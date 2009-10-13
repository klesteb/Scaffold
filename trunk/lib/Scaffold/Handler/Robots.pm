package Scaffold::Handler::Robots;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version    => $VERSION,
  base       => 'Scaffold::Handler',
  filesystem => 'File',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub do_default {
    my ($self) = @_;

    my $doc_rootp = $self->scaffold->config('configs')->{doc_rootp};
    my $file = File($doc_rootp, 'robots.txt');

    if ($file->exists) {

        my $d = $file->read();

        $self->stash->view->data($d);
        $self->stash->view->template_disabled(1);
        $self->stash->view->content_type('text/plain');

    } else {

        $self->not_found($file);

    }

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

  __END__

=head1 NAME

Scaffold::Handler::Static - A handler to handle static files

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
