package Scaffold::Render::TT;

use strict;
use warnings;

our $VERSION = '0.01';

use Template;

use Scaffold::Class
  version  => $VERSION,
  base     => 'Scaffold::Render',
  constant => {
      RENDER => 'scaffold.handler.render',
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub process($) {
    my ($self, $sobj) = @_;

    my $page;
    my $template = $sobj->stash->view->template_wrapper;
    my $vars = {
        view    => $sobj->stash->view,
        configs => $sobj->scaffold->config('configs'),
    };

    $self->engine->process(
        $template,
        $vars,
        \$page
    ) or $self->throw_msg(RENDER, 'template', $template, $self->engine->error);

    return $page;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;

    $self->{config} = $config;

    $self->{engine} = Template->new(
        INCLUDE_PATH => $self->config('include_path'),
    ) or $self->throw_msg(RENDER, 'render', 'TT', $Template::ERROR);

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
