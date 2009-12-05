package Scaffold::Uaf::Authorize;

use strict;
use warnings;

use Scaffold::Uaf::GrantAllRule;
use base qw(Scaffold::Uaf::AuthorizeFactory);

sub rules {
    my $self = shift;

    $self->add_rule(Scaffold::Uaf::GrantAllRule->new());

}

1;

__END__
  
Scaffold::Uaf::Authorize - A default authorization module.

=head1 DESCRIPTION

Scaffold::Uaf::Authorize is a pre-built module that uses 
Scaffold::Uaf::GrantAllRule to implement an authorization scheme. It
is a good idea to overide this module with something better.

=head1 SEE ALSO


=head1 AUTHOR

Kevin L. Esteb

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
