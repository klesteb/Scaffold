package Scaffold::Lockmgr::SharedMem;

use base 'IPC::SharedMem';

use Carp;
use IPC::SysV qw( IPC_SET );

sub set {
    my $self = shift;

    my $ds;

    if (@_ == 1) {

        $ds = shift;

    } else {

        croak 'Bad arg count' if @_ % 2;

        my %arg = @_;

        $ds = $self->stat or return undef;

        while (my ($key, $val) = each %arg) {

            $ds->$key($val);

        }

    }

    my $v = shmctl($self->id, IPC_SET, $ds->pack);
    $v ? 0 + $v : undef;

}

1;
