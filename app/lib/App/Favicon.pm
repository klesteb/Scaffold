package App::Favicon;

our $VERSION = '0.01';

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler::Favicon',
  mixin   => 'Scaffold::Uaf::Authenticate'
;

1;
  