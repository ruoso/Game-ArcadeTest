package Game::ArcadeTest::View::Ball;
use mro 'c3';
use strict;
use warnings;
use base 'Jogo::View::FilledRect';

# we override this to make it use the circle coordinates as center,
# not corner.

sub moved_event_fired {
    my ($self, $ev) = @_;
    $self->$_($ev->new_point->$_ - $self->{radius}) for
        qw(x y);
    return 1;
}

1;
