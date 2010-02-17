package Scaffold;

use 5.008008;
use warnings;
use strict;

our $VERSION = '0.01';

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

=head1 THE CLASS SYSTEM

Object Oriented Perl. There are a lot of ways of doing it. Some are considered
the "next best thing" and/or a "best practice" for Perl and everybody should 
use it, regardless of usability or fitness for that purpose. I choose to use 
the Badger toolkit. Why, because it made sense, it's as simple as that. 

Since the class system is built upon Badger, it follows some of Badger's
methodology. The base class for Scaffold is Scaffold::Base. This loads 
Badger::Base, with all of it's goodness, defines some error messages and 
exposes the config() method. This method is important for other classes 
within Scaffold. 

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

 * Scaffold::Handler::Static    - handles static pages with the option of
                                  storing those pages in cache
 * Scaffold::Handler::Favicon   - load and cache a "favicon.ico" file
 * Scaffold::Handler::Robots    - load and cache a "robots.txt" file
 * Scaffold::Handler::ExtDirect - implement the Ext.direct rpc protocol
 * Scaffold::Handler::ExtPoll   - implement the EXt.direct polling protocol 

=item Scaffold::Plugin

This is the base class for plugins. Plugins are global and they run in 
loaded order. Plugins can be invoked in the following phases of a handler:

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
 * Scaffold::Stash::Cookie     - not currently being used
 * Scaffold::Stash::Controller - not currently being used

=item Scaffold::Cache

This is the base class for the caching subsystem. The following subsystems 
have been defined:

 * Scaffold::Cache::FastMmap
 * Scaffold::Cache::Memcached

Scaffold::Cache::FastMmap is loaded by default. Scaffold::Cache::Manager is
used to manage the cache. It is implemented as a plugin and is the first one
to run. It executes in the STATE_PRE_ACTION phase of a handler. It purges the
cache of expired items.
 
=item Scaffold::Session  

Sessions are handled by HTTP::Session. Sessions are stored in temporary cookies.
Scaffold::Session::Store::Cache ties session storage to the internal caching 
subsystem. Scaffold::Session::Manager initialized or reestablishes existing 
sessions. It is implemented as a plugin. It is the second one to run and 
executes in the STATE_PRE_ACTION to establish sessions and in STATE_PRE_EXIT 
to create or update the session cookie.

=item Scaffold::Lockmgr

This is the base class for implementing a resource lock manager. 
Scaffold::Lockmgr::KeyedMutex uses KeyedMutex as a distributed lock manager. 
It is loaded by default.

=item Scaffold::Uaf

This implements a authorization and authentication framework. The following
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

The following is a plugin that may be overridden:

 * Scaffold::Uaf::Manager - a plugin that checks authentication and 
                            initiates the login process

This has a dependency on Scaffold::Uaf::Authenticate 



For example, a simple 
Scaffold application could be written as follows:

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
to that url and receive a resounding "Hello World!". 

See, simple, no muss, no fuss. 

At its heart, Scaffold::Server is a simple url dispatcher. Sure it
does other things, like, settting up the caching subsystem using Cache::FastMmap,
establishing a session using HTTP::Session, while storing the session meta 
data in the cache subsystem, establishing a resource lock manager 
using Keyedmutex and by default it uses raw html for output. All of these 
defaults can be overridden using the configs. But back to the class system.

Since Scaffold::Server is a simple url dispatcher, it needs to know how to 
map urls to application modules. This is done with the B<locations> config 
stanza. In the above example, "/" is mapped to App::Main. App::Main inherits 
and extends Scaffold::Handler. Scaffold::Handler is a basic state machine. 
Certain states invoke certain actions during the lifetime of a request. Some 
of those states involve plugins. Plugins inherit and extend Scaffold::Plugin.
What plugins are loaded is controled by the B<plugins> stanza. PLugins are 
run in loaded order. By default two plugins are always loaded. They are 
Scaffold::Cache::Manager which manages the cache subsystem and 
Scaffold::Session::Manager which manages the sessions. The request process 
is broken out into these states, which are defined in Scaffold::Constants:

=item STATE_PRE_ACTION

This state is used by plugins to run "pre action" stuff. For example 
Scaffold::Cache::Manager maintains the cache subsystem during this phase, 
it flushes expired items from the cache. While Scaffold::Session::Manager 
checks for and establishes sessions. 

=item STATE_ACTION

Scaffold::Server takes the url and matches it to a handler. That handler then
takes the url and further breaks it down to determine which methods to invoke.
In the above example, "/" resolves to do_main(). If do_main() was not defined,
the handler would then check for do_default(). If neither of them exists a 
declined() exception would have been thrown. 

Now, if a url of "/test" had been passed, the following would happen. First 
the handler would check to see if there was a do_test() method. If there was, 
control would be passed to that method. If there wasn't, then it would check 
to see if there is a do_main() method. If there is, control would be passed 
to do_main() with "test" as the second parameter. If do_main() didn't exist, 
do_default() would be checked for. If it existed, then control would be 
passed to it with "test" as the second parameter. If none of the above, then
a declined() excpetion would be thrown.

Let's try a url of "/test/1". If a do_test() method exited, "1" would be the
second parameter. If do_test() didn't exixt and do_main() did, "test" would 
be the second parameter and "1" would be the third parameter and likewise if
do_main() didn't exist and do_default() did. If none of them exist, a declined()
exception is thrown.


The handler first checks to see if there is a do_main() method, then it 
checks to see if there is a specific


This is where the handler does it thing. For the most part the url is parsed
into its component parts and matched to the locations that are defined. When one
is found it is dispatched too. In the above example do_main() will handle any 
request for "/". You could also have a do_default(). The differance is that 
do_default() could also handle this url "/test". The "test" part of the url
would be the second parameter to do_default(). Another way to handle that url
would be to have a do_test() method. It all depends on how you write your
handler.


 STATE_POST_ACTION
 STATE_PRE_RENDER
 STATE_RENDER
 STATE_POST_RENDER
 STATE_PRE_EXIT
 
=back




provides certain actions 
that can be performed during the lifetime of a request. It can action It is basically a 
state machine. 


So what does this application give you. Well, your application is using 
Cache::FastMmap for caching, a session has been initiated and stored within 
the caching subsystem, a connection to the keyedmutexd daemon has been 
established and you are using raw html for output. 
 


, with ties to the internal caching subsystem.
A distributed, resource locking manager based on Keyedmutex. An user 
authentication and authorization framework that is easily extended
or ignored as you see fit. The freedom to use whatever ORM you desire. I like 
DBIx::Class, you may not. Why should I dictate this choice. The freedom to
use whatever templating engine you want. I like Template Toolkit, you may not,
but I have included the bindings for it. You can easily create your own. 
When you do, please contribute it back, or you can use straight HTML. I don't 
care. How about web server independence, thanks to Plack and the emerging 
PSGI initinitive, that was easy to do.




=head1 AUTHOR

Kevin L. Esteb, C<< <kesteb(at)wsipc.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-scaffold at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Scaffold>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Scaffold


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Scaffold>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Scaffold>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Scaffold>

=item * Search CPAN

L<http://search.cpan.org/dist/Scaffold/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2009 Kevin L. Esteb, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
