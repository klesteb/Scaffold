package Scaffold::Handler::Static;

use strict;
use warnings;

our $VERSION = '0.01';

use MIME::Types 'by_suffix';

use Scaffold::Class
  version    => $VERSION,
  base       => 'Scaffold::Handler',
  constants  => 'TRUE FALSE',
  filesystem => 'File'
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub do_default {
    my ($self, @params) = @_;

    my $found = FALSE;
    my $cache = $self->scaffold->cache;
    my $static_search = $self->scaffold->config('configs')->{static_search};
    my @paths = split(':', $static_search);

    foreach my $path (@paths) {

        my $file = File($path, @params);

        if ($file->exists) {

            my $d;
            my ($mediatype, $encoding) = by_suffix($file);
            $found = TRUE;

            if (! ($d = $cache->get($file))) {

                $d = $file->read();

                $self->stash->view->cache(1);
                $self->stash->view->cache_key($file);

            }

            $self->stash->view->data($d);
            $self->stash->view->template_disabled(1);
            $self->stash->view->content_type(($mediatype || 'text/plain'));

        }

    }

    $self->not_found(File(@params)) if (! $found);

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
