package Scaffold::Handler::Favicon;

use strict;
use warnings;

our $VERSION = '0.01';

use MIME::Types 'by_suffix';

use Scaffold::Class
  version    => $VERSION,
  base       => 'Scaffold::Handler',
  filesystem => 'File'
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub do_default {
    my ($self, @params) = @_;

    my $d;
    my $cache = $self->scaffold->cache;
    my $doc_rootp = $self->scaffold->config('configs')->{doc_rootp};
    my $favicon = $self->scaffold->config('configs')->{favicon};
    my $file = File($doc_rootp, $favicon);

    my ($mediatype, $encoding) = by_suffix($file);

    if (! ($d = $cache->get($file))) {

        if ($file->exists) {

            $d = $file->read();
            $cache->set($file, $d);

        } else {

            $self->not_found($file);

        }

    }

    $self->stash->view->data($d);
    $self->stash->view->template_disabled(1);
    $self->stash->view->content_type(($mediatype || 'text/plain'));

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Handler::Favicon - A handler to handle "favicon.ico" files

=head1 SYNOPSIS

 use Scaffold::Server;

 my $server = Scaffold::Server->new(
    configs => {
        favicon   => 'image.jpeg',
        doc_rootp => 'html'
    },
    locations => {
        '/'            => 'App::Main',
        '/robots.txt'  => 'Scaffold::Handler::Robots',
        '/favicon.ico' => 'Scaffold::Handler::Favicon',
        '/static'      => 'Scaffold::Handler::Static',
    },
 );

=head1 DESCRIPTION

This handler will return a "favicon.ico"  back to the browser. What the 
"favicon" is and where it is located is controlled by the two config options 
"favicon" and "doc_rootp". Once a "favicon" has been requested, subsequent 
requests will load the image from cache instead of disk.

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
