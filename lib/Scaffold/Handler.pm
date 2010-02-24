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
  constants => 'TRUE FALSE :state :plugins',
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

sub handler {
    my ($class, $sobj, $location, $module) = @_;

    $class->{scaffold} = $sobj;
    $class->{stash} = Scaffold::Stash->new(
        cookies => $class->scaffold->request->cookies
    );

    my $configs = $class->scaffold->config('configs');
    my $uri = $class->scaffold->request->uri;
    my $root = $configs->{'app_rootp'};

    $class->{page_title} = $uri->path;

    my $state = STATE_PRE_ACTION;
    my @p = $class->_cleanroot($uri->path, $location);
    my $p1 = ( shift(@p) || 'main');

    my $action = 'do_' . $p1;

    $class->scaffold->response->status('200');
    $class->scaffold->response->header('Content-Type' => 'text/html');

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

        1;

    } or do {

        my $ex = $@;

        if ($class->exceptions($ex, $action, $location, $module)) {

            $class->scaffold->response->body($class->_custom_error($ex));

        }

    };

    $class->_pre_exit();

    return $class->scaffold->response;

}

sub redirect {
    my ($self, $url) = @_;

    my $uri = $self->scaffold->request->uri;
    $url = substr($url, 1);
    $uri->path($url);

    $self->throw_msg(REDIRECT, 'redirect', $uri->canonical);

}

sub moved_permanently {
    my ($self, $url) = @_;

    my $uri = $self->scaffold->request->uri;
    $url = substr($url, 1);
    $uri->path($url);

    $self->throw_msg(MOVED_PERM, 'moved_permanently', $uri->canonical);

}

sub declined {
    my ($self) = @_;

    $self->throw_msg(DECLINED, 'declined', "");

}

sub not_found {
    my ($self, $file) = @_;

    $self->throw_msg(NOTFOUND, 'not_found', $file);

}

sub exceptions {
    my ($self, $ex, $action, $location, $module) = @_;

    my $stat = TRUE;
    my $ref = ref($ex);

    if ($ref && $ex->isa('Badger::Exception')) {

        my $type = $ex->type;
        my $info = $ex->info;
        $stat = FALSE;

        switch ($type) {
            case MOVED_PERM {
                $stat = FALSE;
                $self->scaffold->response->redirect($info, '301');
            }
            case REDIRECT {
                $stat = FALSE;
                $self->scaffold->response->redirect($info, '302');
            }
            case RENDER {
                $stat = FALSE;
                $self->scaffold->response->status('500');
                $self->scaffold->response->body($self->_custom_error($info));
            }
            case DECLINED {
                $stat = FALSE;
                my $text = qq(
                    Declined - undefined method<br />
                    <span style='font-size: .8em'>
                    Method: $action <br />
                    Location: $location <br />
                    Module: $module <br />
                    </span>
                );
                $self->scaffold->response->status('404');
                $self->scaffold->response->body($self->_custom_error($text));
            }
            case NOTFOUND {
                $stat = FALSE;
                my $text = qq(
                    File not found<br />
                    <span style='font-size: .8em'>
                    File: $info<br />
                    </span>
                );
                $self->scaffold->response->status('404');
                $self->scaffold->response->body($self->_custom_error($text));
            }

        }

    }

    return $stat;

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

sub _pre_action {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_ACTION;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $plugin->stash($self->stash);
            $plugin->scaffold($self->scaffold);
            $pstatus = $plugin->pre_action($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _perform_action {
    my ($self, $action , $p1, @p) = @_;

    my $output;

    $self->stash->view->reinit();

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

sub _post_action {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_PRE_RENDER;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $plugin->stash($self->stash);
            $plugin->scaffold($self->scaffold);
            $pstatus = $plugin->post_action($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _pre_render {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_RENDER;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $plugin->stash($self->stash);
            $plugin->scaffold($self->scaffold);
            $pstatus = $plugin->pre_render($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _process_render {
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

            $page = $render->process($self);
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

sub _post_render {
    my ($self) = @_;

    my $pstatus;
    my $status = STATE_FINI;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $plugin->stash($self->stash);
            $plugin->scaffold($self->scaffold);
            $pstatus = $plugin->post_render($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

    return $status;

}

sub _pre_exit {
    my ($self) = @_;

    my $pstatus;

    if (my $plugins = $self->scaffold->plugins) {

        foreach my $plugin (@$plugins) {

            $plugin->stash($self->stash);
            $plugin->scaffold($self->scaffold);
            $pstatus = $plugin->pre_exit($self);
            last if ($pstatus != PLUGIN_NEXT);

        }

    }

}

sub _unexpected_exception {
    my ($self, $type, $info) = @_;

    my $text = qq(
        Unexpected exception caught<br />
        <span style='font-size: .8em'>
        Type: $type<br />
        Info: $info<br />
        </span>
    );

    $self->scaffold->response->status('500');
    $self->scaffold->response->body($self->_custom_error($text));

}

sub _trim {
    my $spaces = $1;

    my $new_sp = " " x int( length($spaces) / 4 );
    return( "\n$new_sp" );
}

sub _dumper_hook {
    $_[0] = bless {
        %{ $_[0] },
        result_source => undef,
    }, ref($_[0]);
}

sub _custom_error {
    my ($self, @err) = @_;

    my $die_msg    = join( "\n", @err );
    my $param_dump = Dumper($self->scaffold->request->param);

    $param_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $param_dump =~ s/</&lt;/g;

    my $request_dump  = Dumper($self->scaffold->request);
    my $response_dump = Dumper($self->scaffold->response);

    local $Data::Dumper::Freezer = '_dumper_hook';
    my $scaffold_dump = Dumper($self->scaffold);

    $request_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $request_dump =~ s/</&lt;/g;

    $response_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $response_dump =~ s/</&lt;/g;

    $scaffold_dump =~ s/(?:^|\n)(\s+)/&_trim( $1 )/ge;
    $scaffold_dump =~ s/</&lt;/g;

    my $status = $self->scaffold->response->status || 'Bad Request';
    my $page = $self->_error_page();

    $page =~ s/##DIE_MESSAGE##/$die_msg/sg;
    $page =~ s/##PARAM_DUMP##/$param_dump/sg;
    $page =~ s/##REQUEST_DUMP##/$request_dump/sg;
    $page =~ s/##RESPONSE_DUMP##/$response_dump/sg;
    $page =~ s/##SCAFFOLD_DUMP##/$scaffold_dump/sg;
    $page =~ s/##STATUS##/$status/sg;
    $page =~ s/##PAGE_TITLE##/$self->page_title/sge;

    return $page;

}

sub _error_page {
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
                <div class="head"><u>Request Object</u></div><br/>
                <pre>
##REQUEST_DUMP##
                </pre>
                <div class="head"><u>Response Object</u></div><br/>
                <pre>
##RESPONSE_DUMP##
                </pre>
                <div class="head"><u>Scaffold Object</u></div><br/>
                <pre>
##SCAFFOLD_DUMP##
                </pre>    
            </div>    
            <div class="name">Running on Scaffold $Scaffold::Base::VERSION</div>
        </div>
    </body>
</html>! 
);
    
}

1;

__END__

=head1 NAME

Scaffold::Handler - The base class for Scaffold URL handlers

=head1 SYNOPSIS

 use Scaffold::Server;

 my $server = Scaffold::Server->new(
    locations => {
        '/'            => 'App::Main',
        '/robots.txt'  => 'Scaffold::Handler::Robots',
        '/favicon.ico' => 'Scaffold::Handler::Favicon',
        '/static'      => 'Scaffold::Handler::Static',
    },
 );

 ...

 package App::Main;

 use Scaffold::Class
   version => '0.01',
   base    => 'Scaffold::Handler',
   filesystem => 'File',
 ;

 sub do_main
     my ($self) = @_;

    $self-view->template_disable(1);
    $self->view->data('<p>Hello World</p>');

 }

 1;

=head1 DESCRIPTION

There are many ways to dispatch and handle requests for a particular URL. 
Scaffold does a simple direct mapping of URL to handler. When the dispatch()
method in Scaffold::Server is invoked it is passed a Plack::Request object. 
The object contains the URL of the request. dispatch() will then parse that 
URL and looks in "locations" for a corresponding handler. If a handler is 
found, that handlers, handler() method is evoked, which further parses the URL 
to determine which methods are called within the handler.

So, for example a request to "/" is made. This would evoke the App::Main 
handler. The handler for App::Main would determine that it should call 
do_main(). do_main() is always called for the root of a URL. If do_main() 
doesn't exist then a call to do_default() will be tried. If neither of these
methods exist a "declined" exception is thrown. 

So, now a request to "/photos' is made. This would also evoke App::Main. Which 
would determine that it should call the do_photos() method. Since there is 
none, it would try to evoke do_default() passing "photos" as the first 
parameter. Since do_default() also doesnt' exist, it will throw a 
"declined" exception.

Now we add a do_photos() method:

 sub do_photos {
     my ($self, $dir, $wanted) = @_;

     my $photo;
     my $file = File($dir, $wanted . '.png');

     if ($file->exists) {

         $photo = $file->read;

         $self->view->data($photo);
         $self->view->template_disable(1);
         $self->view->content_type('image/png');

     } else {

         $self->not_found($file);

     }

 }

The method, do_photos() wants two parameters passed to it. They will be
parsed out of the URL. So a request to "/photos/family/25" is made. The 
App::Main handler is called. The do_photos() method is invoked passing 
"family" and "25" as the two parameters. If the do_photos() method didn't 
exist and a do_default method did, it would be passed three parameters; 
"photos", "family" and "25".

Handlers also run plugins. Plugins are envoked at specific times during the
request's life cycle. They may be used as filters or to perform specific 
actions.

=head1 METHODS

=over 4

=item handler 

The main entry point. This method contains the state machine that handles the
life cycle of a request. It runs the plugins sends the output thru a renderer
for format and returns the response back to the dispatcher.

=item redirect

The method performs a 302 redirect with the specified URL. A fully qualified 
URL is returned in the response header.

 $self->redirect('/login');

Redirects are considered exceptions. When one is generated normal processing
stops and the redirect happens. Since 3xx level http codes are handled directly
by the browser, this method is a prime candiate to override in a single page
JavaScript application. In that case it may return a data structure that has
meaning to the JavaScript application.

=item moved_permanently

The method performs a 301 redirect with the specified URL. A fully qualified 
URL is returned in the response header.

 $self->moved_permanently('/login');

This is considered an exception and normal processing stops.

=item declined

This method performs a 404 response, along with an error page. The error page
shows the location and the handler that was supposed to run along with a dump
of various objects within Scaffold.

 $self->declined();

This is considered an exception and normal processing stops.

=item not_found

This method performs a 404 response, along with an error page. The error page
shows the name of the file that was not found along with a dump of various
objects within Scaffold.

 $self->not_found($file);

This is considered an exception and normal processing stops.

=item exceptions

This method performs exception handling. The methods redirect(), 
moved_permanently(), declined() and not_found() throw exceptions. They are 
handled here. If other exception types need to be handled, this method 
can be overridden.

=back

=head1 SEE ALSO

 Scaffold
 Scaffold::Base
 Scaffold::Cache
 Scaffold::Cache::FastMmap
 Scaffold::Cache::Manager
 Scaffold::Cache::Memcached
 Scaffold::Class
 Scaffold::Constants
 Scaffold::Engine
 Scaffold::Handler
 Scaffold::Handler::Favicon
 Scaffold::Handler::Robots
 Scaffold::Handler::Static
 Scaffold::Lockmgr
 Scaffold::Lockmgr::KeyedMutex
 Scaffold::Plugins
 Scaffold::Render
 Scaffold::Render::Default
 Scaffold::Render::TT
 Scaffold::Server
 Scaffold::Session::Manager
 Scaffold::Stash
 Scaffold::Stash::Controller
 Scaffold::Stash::Cookie
 Scaffold::Stash::View
 Scaffold::Uaf::Authenticate
 Scaffold::Uaf::AuthorizeFactory
 Scaffold::Uaf::Authorize
 Scaffold::Uaf::GrantAllRule
 Scaffold::Uaf::Login
 Scaffold::Uaf::Logout
 Scaffold::Uaf::Manager
 Scaffold::Uaf::Rule
 Scaffold::Uaf::User
 Scaffold::Utils

=head1 AUTHOR

Kevin L. Esteb, E<lt>kesteb@wsipc.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut
