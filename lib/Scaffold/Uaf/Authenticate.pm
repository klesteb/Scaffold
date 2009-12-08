package Scaffold::Uaf::Authenticate;

use 5.008;
use strict;
use warnings;

use Scaffold::Uaf::User;
use Data::Random qw(:all);

our $VERSION = '0.03';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Base',
  utils     => 'encrypt',
  accessors => 'uaf_filter uaf_limit uaf_timeout uaf_secret uaf_login_rootp 
                uaf_denied_rootp uaf_expired_rootp uaf_validate_rootp 
                uaf_login_title uaf_login_wrapper uaf_login_template 
                uaf_denied_title uaf_denied_wrapper uaf_denied_template
                uaf_logout_title uaf_logout_template uaf_logout_wrapper
                uaf_cookie_path uaf_cookie_domain uaf_cookie_secure',
  mixins    => 'uaf_filter uaf_limit uaf_timeout uaf_secret uaf_login_rootp 
                uaf_denied_rootp uaf_expired_rootp uaf_validate_rootp 
                uaf_login_title uaf_login_wrapper uaf_login_template 
                uaf_denied_title uaf_denied_wrapper uaf_denied_template
                uaf_logout_title uaf_logout_template uaf_logout_wrapper
                uaf_cookie_path uaf_cookie_domain uaf_cookie_secure
                uaf_is_valid uaf_validate uaf_invalidate uaf_set_token 
                uaf_avoid uaf_init',
;

use Data::Dumper;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub uaf_is_valid($) {
    my ($self) = @_;

    my $ip;
    my $old_ip;
    my $access;
    my $needed;
    my $old_token;
    my $token = "";
    my $user = undef;

    $ip = $self->scaffold->request->address;
    $token = ($self->scaffold->request->cookies->{'_token_id_'}->value || '');

    my $lock = $self->scaffold->session->session_id;

    if (defined($token) and ($token ne '=')) {

        $old_ip = $self->scaffold->session->get('uaf_remote_ip') || '';
        $old_token = $self->scaffold->session->get('uaf_token') || '';

        # This should work for just about everything except a load
        # balancing, natted firewall. And yeah, they do exist.

        if (($token eq $old_token) and ($ip eq $old_ip)) {

            $user = $self->scaffold->session->get('uaf_user');
            $access = $user->attribute('last_access');
            $user->attribute('last_access', time());
            $self->scaffold->session->set('uaf_user', $user);
            $user = undef if ($access  <  (time() - $self->uaf_timeout));

        }

    }

    return $user;

}

sub uaf_validate($$$) {
    my ($self, $username, $password) = @_;

    my $ip = "";
    my $salt = "";
    my $user = undef;

    $username = lc($username);
    $password = lc($password);
    $ip = $self->scaffold->request->address;
    $salt = rand_chars(set => 'all', min => 5, max => 10);

    if ((($username eq 'admin') and ($password eq 'admin')) or 
        (($username eq 'demo')  and ($password eq 'demo'))) {

        $user = Scaffold::Uaf::User->new($username);

        $user->attribute('login_attempts', 0);
        $user->attribute('last_access', time());
        $user->attribute('salt', $salt);

        $self->scaffold->session->set('uaf_remote_ip', $ip);
        $self->scaffold->session->set('uaf_user', $user);

    }

    return $user;

}

sub invalidate($) {
    my ($self) = @_;

    $self->scaffold->session->remove('uaf_user');
    $self->scaffold->session->remove('uaf_token');
    $self->scaffold->session->remove('uaf_remote_ip');
    $self->scaffold->session->expire();

}

sub uaf_set_token($$) {
    my ($self, $user) = @_;

    my $salt = $user->attribute('salt');
    my $token = encrypt($user->username, ':', time(), ':', $salt, $$);

    $self->scaffold->response->cookies->{'_token_id_'} = {
        value => $token,
        path  => $self->uaf_cookie_path
    };

    $self->scaffold->session->set('uaf_token', $token);

}

sub uaf_avoid($$) {
    my ($self) = @_;

    return 1;

}

sub uaf_init {
    my ($self) = @_;

    my $config = $self->scaffold->config('configs');
    my $app_rootp = $config->{app_rootp};
    
    $app_rootp = '' if ($app_rootp eq '/');

    $self->{uaf_cookie_path}    = $config->{uaf_cookie_path} || '/';
    $self->{uaf_cookie_domain}  = $config->{uaf_cookie_domain} || "";
    $self->{uaf_cookie_secure}  = $config->{uaf_cookie_secure};
    $self->{uaf_limit}          = $config->{uaf_limit} || 3;
    $self->{uaf_timeout}        = $config->{uaf_timeout} || 3600;
    $self->{uaf_secret}         = $config->{uaf_secret} || 'w3s3cR7';
    $self->{uaf_filter}         = $config->{uaf_filter} || qr/^${app_rootp}\/(login|static).*/;

    $self->{uaf_login_rootp}    = $app_rootp . '/login';
    $self->{uaf_denied_rootp}   = $self->{uaf_login_rootp} . '/denied';
    $self->{uaf_expired_rootp}  = $self->{uaf_login_rootp} . '/expired';
    $self->{uaf_validate_rootp} = $self->{uaf_login_rootp} . '/validate';

    # set default login template values

    $self->{uaf_login_title}    = $config->{uaf_login_title} || 'Please Login';
    $self->{uaf_login_wrapper}  = $config->{uaf_login_wrapper} || 'wrapper.tt';
    $self->{uaf_login_template} = $config->{uaf_login_template} || 'uaf_login.tt';

    # set default denied template values

    $self->{uaf_denied_title}    = $config->{uaf_denied_title} || 'Login Denied';
    $self->{uaf_denied_wrapper}  = $config->{uaf_denied_wrapper} || 'wrapper.tt';
    $self->{uaf_denied_template} = $config->{uaf_denied_template} || 'uaf_denied.tt';

    # set default logout template values

    $self->{uaf_logout_title}    = $config->{uaf_logout_title} || 'Logout';
    $self->{uaf_logout_wrapper}  = $config->{uaf_logout_wrapper} || 'wrapper.tt';
    $self->{uaf_logout_template} = $config->{uaf_logout_template} || 'uaf_logout.tt';

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Gantry::Plugins::Uaf::Authenticate - An Basic Authentication Framework

=head1 DESCRIPTION

This class is responsible for authenicating, managing the session store
and creating the User object. This module should be overridden and extended
as needed by your application.

This module understands the following config settings:

 uaf_cookie_path     - The path for the security token, defaults to "/"
 uaf_cookie_domain   - The cookie domain, not currently used
 uaf_cookie_secure   - Wither the cookie should only be used with SSL

 uaf_title           - title for the login page, defaults to 'Please Login"
 uaf_wrapper         - the wrapper for the login page, defaults to "default.tt"
 uaf_template        - the template for the login page, defaults to "login.tt"

 uaf_denied_title    - title for the denied page, defaults to "Login Denied"
 uaf_denied_wrapper  - the wrapper for the denied page, defaults to "default.tt"
 uaf_denied_template - the template for the denied page, defaults to "login_denied.tt"

=over 4

=item new

This initilizes the object, the Gantry object needs to be passed with this
call.

=item is_valid($) 

This method is used to authenticate the current session. The
default authentication behaviour is based on security tokens. A token is 
storeed within the session store and a token is retireved from a cookie. If 
the two match, the session is condsidered autheticate. When the session is 
authenticated an User object is returned.

=item validate($$) 

This method handles the validation of the current session. It accepts two 
parameters. They are a username and password. When the session is validated, 
an User object is created and returned. The default validate() method only 
knows about "admin" and "demo" users, with default passwords of "admin" and 
"demo". This method should be overridden to refelect your applications Users 
datastore and validation policy.

=item invalidate($)

This method will invalidate the current session. You may wish to override this
method. By default it removes the User object form the session store, removes 
the secuity token from the session store and removes the security cookie.

=item login($$)

This method handles the url "/login" and any actions on that url. By default
this method display a simple login page which contains a login form. That form 
is submitted back to the "/login" url, where the username and password are 
processed. This processing is done by the validate() method. If validation is 
succesful an User object is created. This object is then stored within the 
session store so is_valid() can access it when doing session 
authentication. Also an initial security token is created. 

This method also implements a simple three tries at login attempts. If after 
three tries, all attempts are redirected to "/login/denied", which displays 
a simple "denied" page. After a succesful login, a redirect is sent for "/".

=item logout($)

This method handles the url "/logout". It runs the invalidate() method and 
then redirects back to "/".

=item relocate($$)

Handles relocations, it currently just calls the Gantry relocate() 
function.

=item set_token($$)

This method creates the security token. It is passed the User object. The 
default action is to create a token using parts of the User object and
random data. This token is then stored in the session store and sent to the
browser as a cookie.

=item avoid($)

Some application may wish to implement an avoidence scheme for certain
situations. This is a hook to allow that to happen. The default action is
to do nothing.

=item filter($)

This method returns the url filter that is used by uaf_authenticate().

=back

=head1 SEE ALSO

 Gantry
 Gantry::Plugins::Uaf 
 Gantry::Plugins::Uaf::Rule
 Gantry::Plugins::Uaf::User
 Gantry::Plugins::Uaf::Authorize

=head1 AUTHOR

Kevin L. Esteb <kesteb@wsipc.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
