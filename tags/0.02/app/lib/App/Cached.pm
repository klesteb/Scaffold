package App::Cached;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler'
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub do_main {
    my $self = shift;

    my $cache = $self->scaffold->cache;
    my $cached_html;
    my $html = qq(
        <html>
            <head></head>
            <body>
                <p>Cached page</p>
            </body>
        </html>
    );

    if ($cached_html = $cache->get('do_main')) {

        $self->stash->view->data($cached_html);

    } else {

        $self->stash->view->cache(1);
        $self->stash->view->cache_key('do_main');
        $self->stash->view->data($html);

    }

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

App::HelloWorld - A test handler for Scaffold

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
