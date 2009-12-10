package Scaffold::Cache::Manager;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Plugins',
  constants => ':plugins',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub pre_action {
    my ($self, $sobj) = @_;

    $self->scaffold->cache->purge();

    return PLUGIN_NEXT;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

  __END__

=head1 NAME

Scaffold::Cache::Manager - Maintains the cache subsystem for Scaffold

=head1 DESCRIPTION

Scaffold::Cache::Manager is a plugin that maintains the cache system. It 
purges expired items from the cache. It runs in the pre_action phase of 
plugin execution. This plugin is automatically loaded when Scaffold::Server 
initializes. Thus it is the first plugin that is executed.

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
