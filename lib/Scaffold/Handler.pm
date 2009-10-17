package Scaffold::Handler;

use warnings;
use strict;

our $VERSION = '0.01';

use Switch;
use Scaffold::Stash;

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  accessors => 'stash scaffold page_title',
  mutators  => 'is_declined',
  constants => ':state :plugins',
  messages => {
      'declined'          => '%s',
      'redirect'          => "%s",
      'moved_permanently' => "%s",
      'render'            => "%s",
      'not_found'         => "%s",
  },
  constant => {
      DECLINED   => 'scaffold.handler.declined',
      REDIRECT   => 'scaffold.handler.redirect',
      MOVED_PERM => 'scaffold.handler.moved_permanently',
      RENDER     => 'scaffold.handler.render',
      NOTFOUND   => 'scaffold.handler.notfound',
  }
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub handler($$) {
    my ($class, $sobj, $location, $module) = @_;

    $class->{stash} = Scaffold::Stash->new();
    $class->{scaffold} = $sobj;

    my $configs = $class->scaffold->config('configs');
    my $uri = $class->scaffold->request->request_uri || '/';
    my $root = $configs->{'app_rootp'};

    $class->{page_title} = $uri;

    my $state = STATE_PRE_ACTION;
    my @p = $class->_cleanroot($uri, $location);
    my $p1 = ( shift(@p) || 'main');

    my $action = 'do_' . $p1;

    $class->scaffold->response->status('200');
    $class->scaffold->response->header('Content-Type' => 'text/html');

    $class->stash->cookies->data($class->scaffold->request->cookie);

    eval {

        LOOP: 
        while ($state) {

            switch ($state) {
                case STATE_PRE_ACTION {
                    $state = $class->_pre_action();
                }
                case STATE_ACTION {
                    $state = $class->_perform_action($action, $p1, @p);
                }
                case STATE_POST_ACTION {
                    $state = $class->_post_action();
                }
                case STATE_PRE_RENDER {
                    $state = $class->_pre_render();
                }
                case STATE_RENDER {
                    $state = $class->_process_render();
                }
                case STATE_POST_RENDER {
                    $state = $class->_post_render();
                }
                case STATE_FINI {
                    last LOOP;
                }
            };

        }

    }; if (my $ex = $@) {

        my $ref = ref($ex);

        if ($ref && $ex->isa('Badger::Exception')) {

            my $type = $ex->type;
            my $info = $ex->info;

            switch ($type) {
                case MOVED_PERM {
                    $class->scaffold->response->status('301');
                    $class->scaffold->response->header('location' => $info);
                    $class->scaffold->response->body("");
                }
                case REDIRECT {
                    $class->scaffold->response->status('302');
                    $class->scaffold->response->header('location' => $info);
                    $class->scaffold->response->body("");
                }
                case RENDER {
                    $class->scaffold->response->status('500');
                    $class->scaffold->response->body(
                        $class->_custom_error($info)
                    );
                }
                case DECLINED {
                    my $text = qq(
                        Declined - undefined method<br />
                        <span style='font-size: .8em'>
                        Method: $action <br />
                        Location: $location <br />
                        Module: $module <br />
                        </span>
                    );
                    $class->scaffold->response->status('404');
                    $class->scaffold->response->body(
                        $class->_custom_error($text)
                    );
                }
                case NOTFOUND {
                    my $text = qq(
                        File not found<br />
                        <span style='font-size: .8em'>
                        File: $info<br />
                        </span>
                    );
                    $class->scaffold->response->status('404');
                    $class->scaffold->response->body(
                        $class->_custom_error($text)
                    );
                }
                else {
                    if ($class->can('exception_handler')) {

                        $class->exception_handler($ex);

                    } else {

                        my $text = qq(
                            Unexpected exception caught<br />
                            <span style='font-size: .8em'>
                            Type: $type<br />
                            Info: $info<br />
                            </span>
                        );

                        $class->scaffold->response->status('500');
                        $class->scaffold->response->body(
                            $class->_custom_error($text)
                        );

                    }

                }

            };

        } else {

            $class->scaffold->response->body($class->_custom_error($@));

        }

    }

    return $class->scaffold->response;

}

sub redirect($$) {
    my ($self, $url) = @_;

    $self->throw_msg(REDIRECT, 'redirect', $url);

}

sub moved_permanently($$) {
    my ($self, $url) = @_;

    $self->throw_msg(MOVED_PERM, 'moved_permanently', $url);

}

sub declined($) {
    my ($self) = @_;

    $self->throw_msg(DECLINED, 'declined', "");

}

sub not_found($$) {
    my ($self, $file) = @_;

    $self->throw_msg(NOTFOUND, 'not_found', $file);

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub _cleanroot {
    my ($self, $uri, $root) = @_;

    $uri =~ s!^$root!!g;
    $uri =~ s/\/\//\//g;
    $uri =~ s/^\///;

    return(split('/', $uri));

}

sub _pre_action($) {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_ACTION;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $pstatus = $plugin->pre_action($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _perform_action {
    my ($self, $action , $p1, @p) = @_;

    my $output;

    if ($self->can($action)) {

        $self->$action(@p);

    } elsif ($self->can('do_default')) {

        $self->do_default($p1, @p);

    } else {

        $self->declined();

    }

    $self->declined() if ($self->is_declined);

    return STATE_POST_ACTION;

}

sub _post_action($) {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_PRE_RENDER;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $pstatus = $plugin->post_action($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _pre_render($) {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_RENDER;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $pstatus = $plugin->pre_render($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _process_render($) {
    my ($self) = @_;

    my $status = STATE_POST_RENDER;
    my $input = $self->stash->view;
    my $page = $self->stash->view->data;
    my $cache = $self->scaffold->cache;

    # set the content type

    if (my $type = $self->stash->view->content_type) {

        $self->scaffold->response->header('Content-Type' => $type);

    }

    # render the output

    if (my $render = $self->scaffold->render) {

        if (! $input->template_disabled) {

            $page = $render->process($input);
            $self->scaffold->response->body($page);

        } else {

            $self->scaffold->response->body($page);

        }

        # cache the output

        if ($input->cache) {

            $cache->set($input->cache_key, $page);

        }

    } else {

        $self->scaffold->response->body($page);

    }

    return $status;

}

sub _post_render($) {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_FINI;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $pstatus = $plugin->post_render($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _trim {
    my $spaces = $1;

    my $new_sp = " " x int( length($spaces) / 4 );
    return( "\n$new_sp" );
}

sub _custom_error {
    my ($self, @err) = @_;

    eval "use Data::Dumper";

    my $die_msg    = join( "\n", @err );
    my $param_dump = Dumper($self->scaffold->request->param);

    $param_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $param_dump =~ s/</&lt;/g;

    my $request_dump  = Dumper($self);
    my $response_dump = '';

    $request_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $request_dump =~ s/</&lt;/g;

    my $status = $self->scaffold->response->status || 'Bad Request';
    my $page = $self->_error_page();

    $page =~ s/##DIE_MESSAGE##/$die_msg/sg;
    $page =~ s/##PARAM_DUMP##/$param_dump/sg;
    $page =~ s/##REQUEST_DUMP##/$request_dump/sg;
    $page =~ s/##RESPONSE_DUMP##/$response_dump/sg;
    $page =~ s/##STATUS##/$status/sg;
    $page =~ s/##PAGE_TITLE##/$self->page_title/sge;

    return $page;

}

sub _error_page($) {
    my ($self) = @_;
    
    return( qq!
    <html>
    <head>
        <title>##PAGE_TITLE## ##STATUS##</title>
        <style type="text/css">
            body {
                font-family: "Bitstream Vera Sans", "Trebuchet MS", Verdana,
                            Tahoma, Arial, helvetica, sans-serif;
                color: #ddd;
                background-color: #eee;
                margin: 0px;
                padding: 0px;
            }
            div.box {
                background-color: #ccc;
                border: 1px solid #aaa;
                padding: 4px;
                margin: 10px;
                -moz-border-radius: 10px;
            }
            div.error {
                font: 20px Tahoma;
                background-color: #88003A;
                border: 1px solid #755;
                padding: 8px;
                margin: 4px;
                margin-bottom: 10px;
                -moz-border-radius: 10px;
            }
            div.infos {
                font: 9px Tahoma;
                background-color: #779;
                border: 1px solid #575;
                padding: 8px;
                margin: 4px;
                margin-bottom: 10px;
                -moz-border-radius: 10px;
            }
            .head {
                font: 12px Tahoma;
            }
            div.name {
                font: 12px Tahoma;
                background-color: #66B;
                border: 1px solid #557;
                padding: 8px;
                margin: 4px;
                -moz-border-radius: 10px;
            }
        </style>
    </head>
    <body>
        <div class="box">
            <div class="error">##DIE_MESSAGE##</div>
            <div class="infos"><br/>
    
    <div class="head"><u>site.params</u></div>
    <br />
    <pre>
##PARAM_DUMP##
    </pre>
    
    <div class="head"><u>site</u></div><br/>
    <pre>
##REQUEST_DUMP##
    </pre>
    <div class="head"><u>Response</u></div><br/>
    <pre>
##RESPONSE_DUMP##
    </pre>
    
    </div>
    
        <div class="name">Running on Scaffold $Scaffold::Base::VERSION</div>
    </div>
    </body>
    </html>! );
    
}

1;

  __END__

=head1 NAME

Scaffold::Handler - The base class uri method dispatch

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