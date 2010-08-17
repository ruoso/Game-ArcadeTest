package Game::ArcadeTest::View::Ball;
use mro 'c3';
use strict;
use warnings;
use base 'Jogo::View::FilledRect';

# we override this to make it use the circle coordinates as center,
# not corner.

sub render {
    my ($self) = @_;
    $self->SUPER::render();

    my @i = @{$self->{intermediary}};
    $self->{intermediary} = [];
    foreach my $p (@i) {
        my $rect = SDL::Rect->new
          ( $self->{camera}->translate_x_y_w_h( $p->x - $self->{radius},
                                                $p->y - $self->{radius},
                                                $self->{radius} * 2,
                                                $self->{radius} * 2 ) );
        $self->{surface}->blit
          ( $self->{main},
            $self->{rect_obj},
            $rect );
    }
    return 1;
}

sub moved_event_fired {
    my ($self, $ev) = @_;
    $self->$_($ev->new_point->$_ - $self->{radius}) for
        qw(x y);

    $self->{intermediary} ||= [];
    push @{$self->{intermediary}}, $ev->new_point;

    return 1;
}

1;
