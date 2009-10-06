package Scaffold::Constants;

use strict;
use warnings;

use base 'Badger::Constants';

use constant {
    LOCK => '__LOCK__',
};

our $EXPORT_ALL = 'LOCK';
  
our $EXPORT_ANY = 'LOCK';

our $EXPORT_TAGS = {
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
