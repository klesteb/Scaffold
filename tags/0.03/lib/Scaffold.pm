package Scaffold;

use 5.8.8;
use warnings;
use strict;

our $VERSION = '0.03';

1; 

__END__

=head1 NAME

Scaffold - A web application framework

=head1 INTRODUCTION

Ahh, what the world needs, "yet another web application framework". So, 
what makes mine better then the others? Nothing really. This was born out of 
my frustrations with trying to use another "web application framework'.

So what does Scaffold give you? Well, it won't create a stand alone 
application from a simple command line. It won't give you yet another 
ORMish way to access your databases. It won't auto-generate a lot of boiler 
plate code. It won't even boast about how independent it is from CPAN. Nor will
it attempt to re-invent Ruby-on-Rails, Django or whatever the framework dejour 
currently is.

What it does gives you is the freedom to write your web based application as 
you see fit. Scaffold brings the following to the table. 

=over 4

 * A comprehensive object structure.
 * A caching subsystem. 
 * Session management
 * A locking resource manager
 * Freedom to choose an ORM
 * Bindings to the Template Toolkit
 * Web server independence

=back

This is all done thru readily available CPAN modules.

What I needed was a simple, easy to use framework that provided caching, 
session management, resource locking, templating and a URL dispatching system, 
without any preconceived notions on how I should write my code. Scaffold is 
my attempt to do this. I hope it works for you too.

=head1 THE BASIC SYSTEM

Scaffold is an OO based system and OO Perl can be done many 
different ways. Some are considered the "next best thing" and/or a "best 
practice" for Perl and everybody should use it, regardless of usability or 
fitness for that purpose. I choose to use the Badger toolkit. Why, because 
it made sense, it's as simple as that.

Since the class system is built upon Badger, it follows some of Badger's
methodology. The base class for Scaffold is Scaffold::Base. This loads 
Badger::Base, with all of it's goodness, defines some error messages and 
exposes the config() method. This method is important for other classes 
within Scaffold. 

=over 4

=item Scaffold::Class

This class extends Badger::Class and loads Scaffold::Constants and 
Scaffold::Utils. Which extends their respected Badger counter parts. 
Scaffold::Constants defines some global constants used within Scaffold. 
Scaffold::Utils loads some common utilities that other modules can make 
usage of. Since Scaffold::Class extends Badger::Class, you can use 
Badger's meta language within your own modules.

=item Scaffold::Server 

This is the main entry point to Scaffold. This processes the configuration 
and loads the various components. Scaffold::Server also parses the URL and
invokes handler's to handle the processing of the URL. If there are
no corresponding handlers, an exception is thrown.

=item Scaffold::Engine

This ties Scaffold::Server to the Plack back end.

=item Scaffold::Handler

This is the base class for handlers. It further breaks down the URL to
determine which method to invoke. If a method does not match the URL an 
exception is thrown. Scaffold::Handler is also a state machine.
The following states are defined:

 STATE_PRE_ACTION
 STATE_ACTION
 STATE_POST_ACTION
 STATE_PRE_RENDER
 STATE_RENDER
 STATE_POST_RENDER
 STATE_PRE_EXIT
 
The following handlers are provided:

 * Scaffold::Handler::Static    - handles static pages with the 
                                  option of storing those pages in 
                                  cache
 * Scaffold::Handler::Favicon   - load and cache a "favicon.ico" file
 * Scaffold::Handler::Robots    - load and cache a "robots.txt" file
 * Scaffold::Handler::ExtDirect - an experimental implementation of the 
                                  Ext.direct RPC protocol
 * Scaffold::Handler::ExtPoll   - an experimental implementing of the 
                                  Ext.direct polling protocol

=item Scaffold::Plugin

This is the base class for plug-ins. Plug-ins are global and they run in 
loaded order. Plug-ins can be invoked in the following phases of a handler:

 STATE_PRE_ACTION
 STATE_POST_ACTION
 STATE_PER_RENDER
 STATE_POST_RENDER
 STATE_PRE_EXIT

=item Scaffold::Render

This is the base class for renderer's. A render, formats the output before it
is sent to the browser. By default, this is a raw buffer. Scaffold::Reneder::TT
is the interface to the Template Toolkit. The renderer is invoked in the 
STATE_RENDER phase of a handler.

=item Scaffold::Stash

This is the base class for stashes. A stash is global to a handler. 
The following stashes have been defined:

 * Scaffold::Stash::View       - used to hold the output buffer
 * Scaffold::Stash::Cookie     - used to hold the cookies
 * Scaffold::Stash::Controller - not currently being used

=item Scaffold::Cache

This is the base class for the caching subsystem. The following subsystems 
have been defined:

 * Scaffold::Cache::FastMmap
 * Scaffold::Cache::Memcached

Scaffold::Cache::FastMmap is loaded by default. Scaffold::Cache::Manager is
used to manage the cache. It is implemented as a plug-in and is the first one
to run. It executes in the STATE_PRE_ACTION phase of a handler. It purges the
cache of expired items.
 
=item Scaffold::Session  

Sessions are handled by HTTP::Session. Sessions are stored in temporary cookies.
Scaffold::Session::Store::Cache ties session storage to the internal caching 
subsystem. Scaffold::Session::Manager initialized or reestablishes existing 
sessions. It is implemented as a plug-in. It is the second one to run and 
executes in the STATE_PRE_ACTION to establish sessions and in STATE_PRE_EXIT 
to create or update the session cookie.

=item Scaffold::Lockmgr

This is the base class for implementing a resource lock manager. 
Scaffold::Lockmgr::KeyedMutex uses KeyedMutex as a distributed lock manager. 
It is loaded by default.

=item Scaffold::Uaf

This implements an authorization and authentication framework. The following
modules are base classes and most of them should be overridden by your code.

 * Scaffold::Uaf::Authenticate - this is a mixin used for authentication
 * Scaffold::Uaf::Authorize    - this is a base class for authorizations
 * Scaffold::Uaf::Rule         - a base class for rules
 * Scaffold::Uaf::User         - a base class for the user object
 
The following are defaults that should be overridden:

 * Scaffold::Uaf::AuthorizeFactory - a default authorization scheme
 * Scaffold::Uaf::GrantAllRule     - a default rule that grants everything

The following are handlers that may be overridden:

 * Scaffold::Uaf::Login  - a handler for authentication
 * Scaffold::Uaf::Logout - a handler to expire an authentication

They have a dependency on Scaffold::Uaf::Authenticate.

The following is a plug-in that may be overridden:

 * Scaffold::Uaf::Manager - a plugin that checks authentication and 
                            initiates the login process

This has a dependency on Scaffold::Uaf::Authenticate 

=back

=head1 A SIMPLE APPLICATION

For example, a simple Scaffold application could be written as follows:

 app.psgi
 --------

 use lib 'lib';
 use Scaffold::Server;

 my $psgi_handler;
 my $server = Scaffold::Server->new(
    locations => {
        '/' => 'App::Main',
    }
 );

 $psgi_handler = $server->engine->psgi_handler();

 ...
 
 package App::Main;

 use Scaffold::Class
    version => '0.01',
    base    => 'Scaffold::Handler',
 ;

 sub do_main
    my ($self) = @_;

    my $html => qq(
       <html>
         <head>
           <title>Hello World</title>
         </head>
         <body>
           <p>Hello World!</p>
         </body>
       </html>
    );

    $self->view->data($html);

 }

 ...

 # plackup -app app.psgi

Which would start your application on port 5000 of localhost using the 
singled threaded Plack server engine. You can direct your browser 
to that URL and receive a resounding "Hello World!". 

See, simple, no muss, no fuss. 

=head1 SEE ALSO

 Scaffold::Base
 Scaffold::Class
 Scaffold::Constants
 Scaffold::Engine
 Scaffold::Server
 Scaffold::Utils

 Scaffold::Cache
 Scaffold::Cache::FastMmap
 Scaffold::Cache::Manager
 Scaffold::Cache::Memcached

 Scaffold::Handler
 Scaffold::Handler::ExtDirect
 Scaffold::Handler::ExtPoll
 Scaffold::Handler::Favicon
 Scaffold::Handler::Robots
 Scaffold::Handler::Static

 Scaffold::Lockmgr
 Scaffold::Lockmgr::KeyedMutex
 Scaffold::Lockmgr::UnixMutex

 Scaffold::Plugins

 Scaffold::Render
 Scaffold::Render::Default
 Scaffold::Render::TT

 Scaffold::Session::Manager
 Scaffold::Session::Store
 Scaffold::Session::Store::Cache

 Scaffold::Stash
 Scaffold::Stash::Controller
 Scaffold::Stash::Cookies
 Scaffold::Stash::Manager
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

=head1 AUTHOR

Kevin L. Esteb, C<< <kesteb(at)wsipc.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Scaffold

=head1 COPYRIGHT & LICENSE

Copyright 2010 Kevin L. Esteb, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
