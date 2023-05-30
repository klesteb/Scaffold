#!perl -T

use Test::More tests => 42;

BEGIN {
	use_ok( 'Scaffold::Base' );
	use_ok( 'Scaffold::Cache' );
	use_ok( 'Scaffold::Class' );
	use_ok( 'Scaffold::Constants' );
	use_ok( 'Scaffold::Engine' );
	use_ok( 'Scaffold::Exception' );
	use_ok( 'Scaffold::Handler' );
	use_ok( 'Scaffold::Lockmgr' );
	use_ok( 'Scaffold::Plugins' );
	use_ok( 'Scaffold::Render' );
	use_ok( 'Scaffold::Routes' );
	use_ok( 'Scaffold::Server' );
	use_ok( 'Scaffold::Stash' );
	use_ok( 'Scaffold::Utils' );
	use_ok( 'Scaffold::Cache::FastMmap' );
	use_ok( 'Scaffold::Cache::Manager' );
	use_ok( 'Scaffold::Cache::Memcached' );
	use_ok( 'Scaffold::Handler::Default' );
	use_ok( 'Scaffold::Handler::ExtDirect' );
	use_ok( 'Scaffold::Handler::ExtPoll' );
	use_ok( 'Scaffold::Handler::Robots' );
	use_ok( 'Scaffold::Handler::Favicon' );
	use_ok( 'Scaffold::Handler::Static' );
	use_ok( 'Scaffold::Lockmgr::KeyedMutex' );
	use_ok( 'Scaffold::Lockmgr::SharedMem' );
	use_ok( 'Scaffold::Lockmgr::UnixMutex' );
	use_ok( 'Scaffold::Render::Default' );
	use_ok( 'Scaffold::Render::TT' );
	use_ok( 'Scaffold::Session::Manager' );
	use_ok( 'Scaffold::Session::Store::Cache' );
	use_ok( 'Scaffold::Stash::Controller' );
	use_ok( 'Scaffold::Stash::Cookies' );
	use_ok( 'Scaffold::Stash::Manager' );
	use_ok( 'Scaffold::Stash::View' );
	use_ok( 'Scaffold::Uaf::Authenticate' );
	use_ok( 'Scaffold::Uaf::AuthorizeFactory' );
	use_ok( 'Scaffold::Uaf::Authorize' );
	use_ok( 'Scaffold::Uaf::GrantAllRule' );
	use_ok( 'Scaffold::Uaf::Login' );
	use_ok( 'Scaffold::Uaf::Logout' );
	use_ok( 'Scaffold::Uaf::User' );
	use_ok( 'Scaffold' );
}

diag( "Testing Scaffold $Scaffold::VERSION, Perl $], $^X" );
