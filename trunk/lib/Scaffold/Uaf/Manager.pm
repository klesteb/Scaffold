package Scaffold::Uaf::Manager;

use strict;
use warnings;

our $VERSION = '0.01';

use Scaffold::Class
  version   => $VERSION,
  base      => 'Scaffold::Plugins',
  constants => ':plugins',
  mixin     => 'Scaffold::Uaf::Authenticate',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub pre_action($$) {
    my ($self, $sobj) = @_;

    
    $self->uaf_init();

    my $user;
    my $regex = $self->uaf_filter;
    my $uri = $sobj->scaffold->request->uri;
    my $login_rootp = $self->uaf_login_rootp;
    my $lock = $sobj->scaffold->session->session_id;

    # authenticate the session, this happens with each access

    if ($uri->path !~ /^$regex/) {

        if ($self->uaf_avoid()) {

            if ($sobj->scaffold->lockmgr->lock($lock)) {

                if ($user = $self->uaf_is_valid()) {

                    #
                    # Uncomment this line of code and you will get an 
                    # everchanging security token. Some internet pundits 
                    # consider this a "good thing". But in an xhr async 
                    # environment you will get a rather nasty race condition. 
                    # i.e. The browsers don't consistently update the cookies 
                    # from xhr requests. While a standard page loads work 
                    # quite nicely.
                    #
                    # --> $self->set_token($user);
                    #

                    $sobj->scaffold->user($user);
                    $sobj->scaffold->lockmgr->unlock($lock);

                } else { 

                    $sobj->scaffold->lockmgr->unlock($lock);
                    $sobj->redirect($login_rootp); 

                }

            }

        }

    }

    return PLUGIN_NEXT;

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

Gantry::Plugins::Uaf - A User Authentication and Authorization Framework

=head1 SYNOPSIS

In the Apache Perl startup or app.cgi or app.server:

    <Perl>
        # ...
        use MyApp qw{ -Engine=CGI -TemplateEngine=TT Cache Session Uaf};
    </Perl>
    
Inside MyApp.pm:

    use Gantry::Plugins::Uaf;

=head1 DESCRIPTION

This plugin mixes in a method that will provide session authentication and 
user authorization. Session authentication is based on a valid username and 
password. While user authorization is based on application defined rules 
which grant access to resources. The goal of this module is to be 
simple and flexiable.

To met this goal four objects are defined. They are Authenticate, 
Authorize, User and Rule. This package provides basic implementations of 
those objects. 

The Rule object either grants or denies access to a resource. The access is 
anything you want to use. A resource can be anything you define.

The User object consists of username and attributes. You can define as many 
and whatever attributes you want. The User object is not tied to any one 
datastore.

The base Authenticate object has two users hardcoded within. Those users are
"admin" and "demo", with corresponding passwords. This object handles the
authentication along with basic login and logout functionality.

The base Authorization object has only one rule defined: AllowAll.

Using the default, provided, Authentication and Authorization modules should
allow you get your application up and running in minimal time. Once that is
done, then you can define your User datastore, what your application rules 
are and then create your objects. Once you do that, then you can load
your own modules with the following config variables.

 uaf_authn_factory - The module name for your Authentication object
 uaf_authz_factory - The module name for your Authorization object

The defaults for those are:

 Gantry::Plugins::Uaf::Authorize
 Gantry::Plugins::Uaf::Authenticate

These modules must be on the Perl include path and are loaded during
Gantry's startup processing. This plugin also requires the Session plugin. 

=head1 METHODS

=over 4

=item uaf_authenticate

The method that is called for every url. It controls the authentication 
process, loads the User object and sets the scurity token.

=back

=head1 ACCESSORS

=over 4

=item uaf_authn

Returns the handle for the Authentication object.

=item uaf_authz

Returns the handle for the Authorization object.

Example:

=over 4

 $manager = $gobj->uaf_authz;
 if ($manager->can($user, "read", "data")) {

 }

=back

=item uaf_user

Set/Returns the handle for the User object.

Example:

=over 4

 $user = $gobj->uaf_user;
 $gobj->uaf_user($user);

=back

=back

=head1 PRIVATE METHODS

=over 4

=item get_callbacks

For use by Gantry. Registers the callbacks needed by Uaf
during the PerlHandler Apache phase or its moral equivalent.

=item initialize

This method is called by Gantry it will load and initialize your Authentication
and Authorization modules.

=item do_login

Exposes the url "/login", and calls the login() method of your Authenticaton 
module.

=item do_logout

Exposes the url "/logout", and calls the logout() method of your Authentication
module.

=back

=head1 SEE ALSO

 Gantry
 Gantry::Plugins::Session
 Gantry::Plugins::Uaf::Rule
 Gantry::Plugins::Uaf::User
 Gantry::Plugins::Uaf::Authorize
 Gantry::Plugins::Uaf::Authenticate
 Gantry::Plugins::Uaf::AuthorizeFactory

=head1 ACKNOWLEGEMENT

This module was heavily influenced by Apache2::SiteControl 
written by Tony Kay, E<lt>tkay@uoregon.eduE<gt>.

=head1 AUTHOR

Kevin L. Esteb <kesteb@wsipc.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Kevin L. Esteb

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
