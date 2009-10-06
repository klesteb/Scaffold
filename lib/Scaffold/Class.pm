package Scaffold::Class;

use Badger::Class
  uber     => 'Badger::Class',
  constant => {
      CONSTANTS => 'Scaffold::Constants',
  }
;

1;

__END__

=head1 NAME

Scaffold::Class - A Perl extension for the Supervisor environment

=head1 SYNOPSIS

 use Scaffold::Class
    version => '0.01',
    base    => 'Scaffold::Base',
   ...
 ;
   
=head1 DESCRIPTION

This module inherits from Badger::Class and exposes the additinoal constants 
and utiltiy functions that are needed by the Scaffold environment.

=head1 SEE ALSO

 Badger::Class

 Scaffold::Base
 Scaffold::Class

=head1 AUTHOR

Kevin Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
