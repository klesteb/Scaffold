package Scaffold::Utils;

use strict;
use warnings;

our $VERSION = '0.01';

use Crypt::CBC;
use Badger::Exception;
use Digest::MD5 'md5_hex';

use Scaffold::Class
  version    => $VERSION,
  base       => 'Badger::Utils',
  codec      => 'Base64',
  filesystem => 'File',
  exports => {
      any => 'encrypt decrypt init_module',
  },
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub decrypt {
    my ($secret, $encrypted) = @_;

    my $c;
    my $md5;
    my $omd5;
    my $p_text;
    my @decrypted_values;

    $encrypted ||= '';

    local $^W = 0;

    eval {

        $c = new Crypt::CBC ( 
            {
                'key'     => $secret,
                'cipher'  => 'Blowfish',
                'padding' => 'null',
            } 
        );

    }; if (my $x = $@) {

        my $ex = Badger::Exception->new(
            type => 'scaffold.utils.decrypt',
            info => sprintf("error building CBC object: %s", $x),
        );

        $ex->throw;

    }

    $p_text = $c->decrypt(decode($encrypted));
    $c->finish();

    @decrypted_values = split(':;:', $p_text);
    $md5 = pop(@decrypted_values);
    $omd5 = md5_hex(join('', @decrypted_values)) || '';

    if ($omd5 eq $md5) {

        if (wantarray) {

            return @decrypted_values;

        } else {

            return join(' ', @decrypted_values);

        }

    } else {

        my $ex = Badger::Exception->new(
            type => 'scaffold.utils.decrypt',
            info => "bad encryption",
        );

        $ex->throw;

    }

}

sub encrypt {
    my ($secret, @to_encrypt) = @_;

    my $c;
    my $md5;
    my $str;
    my $encd;
    my $c_text;
    my $msg = 'scaffold.utils.encrypt';

    local $^W = 0;

    eval {

        $c = new Crypt::CBC( 
            {
                'key'     => $secret,
                'cipher'  => 'Blowfish',
                'padding' => 'null',
            } 
        );

    }; if (my $x = $@) {

        my $ex = Badger::Exception->new(
            type => 'scaffold.utils.encrypt',
            info => sprintf("error building CBC object: %s", $x),
        );

        $ex->throw;

    }

    $md5 = md5_hex(join('', @to_encrypt));
    push(@to_encrypt, $md5);

    $str    = join(':;:', @to_encrypt);
    $encd   = $c->encrypt($str);
    $c_text = encode($encd, '');

    $c->finish();

    return $c_text;

}

sub init_module {
    my ($module) = @_;

    my @parts = split("::", $module);
    my $filename = File(@parts);

    require $filename . '.pm';
    $module->import();
    my $obj = $module->new();

    return $obj;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Scaffold::Utils - Utilitiy functions for Scaffold

=head1 SYNOPSIS

This module provides some basic utility functions for Scaffold.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item encrypt( 'value' [, ... ] )

encrypts and returns the encrypted string

=item decrypt( 'string' )

decrypts and returns the values

=item init_module( 'module' )

load and initializes a module

=back

=head1 SEE ALSO

 Badger::Utils

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
