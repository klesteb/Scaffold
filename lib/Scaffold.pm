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
it attempt to re-invent Ruby-on-Rails or whatever the framework dejour 
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
session management, resource locking, templating and a url dispatching system, 
without any preconceived notions on how I should write my code. Scaffold is my
attempt to do this. I hope it works for you too.

=head1 The Scaffold Class System

Object Oriented Perl. There are a lot of ways of doing it. Some are considered
the "next best thing" for Perl and everybody should use it, reguardless of 
usability or fitness for the purpose. I choose to use the Badger toolkit. Why,
because it made sense, it's as simple as that. 

The base class for Scaffold is Scaffold::Base. This loads Badger::Base, with 
all of it's goodness, defines some error messages and exposes the config() 
method. This method is important for other classes within Scaffold. 

The next class is Scaffold::Class


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


A simple Scaffold application could be written as follows:

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

Which would start your application on port 5000 of localhost. Direct 
your browser to that url and recieve a resounding "Hello World!". 

So what does this application give you. Well, your application is using 
Cache::FastMmap for caching, a session has been initiated and stored within 
the caching subsystem, a connection to the keyedmutexd daemon has been 
established and you are using raw html for output. 


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
