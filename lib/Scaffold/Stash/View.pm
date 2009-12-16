package Scaffold::Stash::View;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  constants => 'FALSE',
  mutators  => 'title template data template_disabled template_wrapper 
                template_default content_type cache cache_key',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub reinit {
    my ($self) = @_;

    $self->title('');
    $self->data('');
    $self->cache(FALSE);
    $self->template('');
    $self->cache_key('');
    $self->content_type('');
    $self->template_default('');
    $self->template_wrapper('');
    $self->template_disabled(FALSE);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Stash::View - 

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
