package Scaffold::Handler;

use warnings;
use strict;

our $VERSION = '0.01';

use Switch;
use Badger::Exception;
use Scaffold::Constants ':state';

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub handler($$$$) {
    my ($class, $sobj, $request, $response) - @_;

    eval {

        while ($state) {

            switch ($state) {
                case STATE_CACHED_PAGES {
                    $state = cached_pages($self);
                }
                case STATE_PRE_ACTION {
                    $state = pre_action($self, $plugin_callbacks);
                }
                case STATE_ACTION {
                    $state = perform_action($self);
                }
                case STATE_POST_ACTION {
                    $state = post_action($self, $plugin_callbacks);
                }
                case STATE_PRE_PROCESS {
                    $state = pre_process($self, $plugin_callbacks);
                }
                case STATE_PROCESS {
                    $state = process_template($self);
                }
                case STATE_POST_PROCESS {
                    $state = post_process($self, $plugin_callbacks);
                }
            };

        }

    }; if (my $ex = $@) {

        my $ref = ref($X);

        if ($ref && $X->isa('Gantry::Exception::Redirect')) {

            $self->header_out('location', "$X");
            $self->redirect_response();
            $status = $self->status_const('REDIRECT');

        } elsif ($ref && $X->isa('Gantry::Exception::RedirectPermanently')) {

            $self->header_out('location', "$X");
            $self->redirect_response();
            $status = $self->status_const('MOVED_PERMANENTLY');

        } elsif ($ref && $X->isa('Gantry::Exception::Declined')) {

            $status = $self->declined_response($self->action());

        } elsif ($ref && $X->isa('Gantry::Exception')) {

            if ($self->can('exception_handler')) {

                $status = $self->exception_handler($X);

            } else {

                warn "Unexpected exception caught:\n";
                warn "  status = " . $X->status . "\n";
                warn "  message = " . $X->message . "\n";
                $status = 500;

            }

        } else {

            # Call do_error and return

            $self->do_error($X);
            $status = $self->cast_custom_error($self->custom_error($X), $X);

        }

    }

    return $response;
    
}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

__END__

=head1 NAME

Scaffold::Handler - The base class uri method dispatch

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
