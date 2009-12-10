package Scaffold::Base;

our $VERSION = '0.01';

use Scaffold::Class
  base     => 'Badger::Base',
  version  => $VERSION,
  messages => {
      evenparams => "%s requires an even number of paramters\n",
      noalias    => "can not set session alias %s\n",
      badini     => "can not load %s\n",
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub config {
    my ($self, $p) = @_;

    return $self->{config}->{$p};

}

1;

__END__

=head1 NAME

Scaffold::Base - The Base environment for Scaffold

=head1 SYNOPSIS

 use Scaffold::Class
   version => '0.01',
   base    => 'Scaffold::Base'
 ;

=head1 DESCRIPTION

This is the base class for Scaffold. It defines some useful exception messages
and a method to access the config cache.

=head1 ACCESSORS

=over 4

=item config

This method is used to return items from the interal config cache.

=back

=head1 SEE ALSO

 Badger::Base

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
