package App::Robots;

our $VERSION = '0.01';

use Scaffold::Class
  version => $VERSION,
  base    => 'Scaffold::Handler::Robots',
  mixin   => 'Scaffold::Uaf::Authenticate'
;

1;
  