package Scaffold::Exception;

use base Badger::Exception;
$Badger::Exception::TRACE = 1;

1;

__END__
  
=head1 NAME

Scaffold::Exception - The exception class for the Scaffold environment
  
=head1 DESCRIPTION

This module defines the exception class for the Scaffold Environment and 
inherits from Badger::Exception. The only differences is that it turns
stack tracing on by default.
  
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
 Scaffold::Handler::Default
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
 Scaffold::Routes
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

Kevin L. Esteb, E<lt>kevin(at)kesteb.usE<gt>
  
=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kevin L. Esteb
  
This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself, either Perl version 5.8.8 or,
  at your option, any later version of Perl 5 you may have available.
  
=cut
