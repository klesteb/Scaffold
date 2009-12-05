package Scaffold::Plugins;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  constants => ':plugins',
  accessors => 'scaffold',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub pre_action($$) {
    my ($self, $sobj) = @_;

    return PLUGIN_NEXT;

}

sub post_action($$) {
    my ($self, $sobj) = @_;

    return PLUGIN_NEXT;

}

sub pre_render($$) {
    my ($self, $sobj) = @_;

    return PLUGIN_NEXT;

}

sub post_render($$) {
    my ($self, $sobj) = @_;

    return PLUGIN_NEXT;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

  __END__

=head1 NAME

Scaffold::Plugins - The base class for Scaffold plugins

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
