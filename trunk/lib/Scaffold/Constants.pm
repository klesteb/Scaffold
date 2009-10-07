package Scaffold::Constants;

use strict;
use warnings;

use base 'Badger::Constants';

use constant {
    LOCK               => '__LOCK__',
    STATE_CACHED_PAGES => 1,
    STATE_PRE_ACTION   => 2,
    STATE_ACTION       => 3,
    STATE_POST_ACTION  => 4,
    STATE_PRE_PROCESS  => 5,
    STATE_PROCESS      => 6,
    STATE_POST_PROCESS => 7,
    STATE_FINI         => 8,
};

our $EXPORT_ALL = 'LOCKSTATE_CACHED_PAGES STATE_PRE_ACTION STATE_ACTION
                   STATE_POST_ACTION STATE_PRE_PROCESS STATE_PROCESS
                   STATE_POST_PROCESS STATE_FINI'
;

our $EXPORT_ANY = 'LOCK STATE_CACHED_PAGES STATE_PRE_ACTION STATE_ACTION
                   STATE_POST_ACTION STATE_PRE_PROCESS STATE_PROCESS
                   STATE_POST_PROCESS STATE_FINI'
;

our $EXPORT_TAGS = {
    state => 'STATE_CACHED_PAGES STATE_PRE_ACTION STATE_ACTION
              STATE_POST_ACTION STATE_PRE_PROCESS STATE_PROCESS
              STATE_POST_PROCESS STATE_FINI',
};

1;

__END__

=head1 NAME

Scaffold::Constants - Define useful constants for Scaffold

=head1 SYNOPSIS

 use Scaffolc::Class
   version => '0.01',
   base    => 'Scaffold::Base',
   constants => 'LOCK'
 ;

=head1 DESCRIPTION

=head1 EXPORTS

=head1 SEE ALSO

=head1 AUTHOR

Kevin Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
