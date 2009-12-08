package Scaffold::Utils;

use strict;
use warnings;

our $VERSION = '0.01';

use Crypt::CBC;
use Digest::MD5 'md5_hex';

use Scaffold::Class
  version => $VERSION,
  base    => 'Badger::Utils',
  codec   => 'Base64',
  exports => {
      any => 'encrypt decrypt',
  },
  messages => {
      'badcrypt' => "error building CBC object: %s",
      'nocrypt'  => 'bad encryption',
  },
  constant => {
      Exception => __PACKAGE__,
  }
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
    my $msg = 'scaffold.utils.decrypt';

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

    }; if (my $ex = $@) {

        Exception->throw_msg($msg, 'badcyrpt', $ex);

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

        Exception->throw_msg($msg, 'nocrypt');

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

    }; if (my $ex = $@) {

        Exception->throw_msg($msg, 'badcrypt', $ex);

    }

    $md5 = md5_hex(join('', @to_encrypt));
    push(@to_encrypt, $md5);

    $str    = join(':;:', @to_encrypt);
    $encd   = $c->encrypt($str);
    $c_text = encode($encd, '');

    $c->finish();

    return $c_text;

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

=back

=head1 SEE ALSO

 Badger::Base

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
