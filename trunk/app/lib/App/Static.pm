package App::Static;

our $VERSION = '0.01';

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler::Static',
  mixin   => 'Scaffold::Uaf::Authenticate'
;

1;
  