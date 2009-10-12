package Scaffold::Render::TT;

use strict;
use warnings;

our $VERSION = '0.01';

use Template;

use Scaffold::Class
  version  => $VERSION,
  base     => 'Scaffold::Render',
  constants => {
      RENDER => 'scaffold.handler.render',
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub process($$) {
    my ($self, $input) = @_;

    my $page;

    $self->scaffold->render->engine->process(
        $input->template,
        {
            self => $self,
            site => $self,
            view => $input,
        },
        \$page
    ) or $self->throw_msg(RENDER, 'render', 'TT', $self->scaffold->render->engine->error);

    return $page;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    my @wrappers = split(':', $self->config('wrappers'));
    my @defaults = split(':', $self->config('defaults'));
    my @include_paths = split(':', $self->config('include_paths'));

    $self->{engine} = Template->new(
        WRAPPER      => \@wrappers,
        INCLUDE_PATH => \@include_paths,
        DEFAULT      => \@defaules
    ) or $self->throw_msg(TEMPLATE, 'template', $Template::ERROR);

    return $self;

}

1;

__END__

=head1 NAME

Scaffold::Render::TT - Use the Template Toolkit to render pages.

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
