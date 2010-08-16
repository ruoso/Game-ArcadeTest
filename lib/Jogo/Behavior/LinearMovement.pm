package Jogo::Behavior::LinearMovement;
use strict;
use warnings;
use base 'Jogo::Point';
use aliased 'Jogo::Type::Point';
use aliased 'Jogo::Event::Moved';

sub x_vel {
    my $self = shift;
    $self->{x_vel} = shift if @_;
    return $self->{x_vel} || 0;
}

sub y_vel {
    my $self = shift;
    $self->{y_vel} = shift if @_;
    return $self->{y_vel} || 0;
}


sub time_lapse {
    my ($self, $old_time, $new_time) = @_;

    my $x = $self->x;
    my $y = $self->y;

    my $old = Point->new(x => $x, y => $y);

    $x += ($new_time - $old_time) * $self->x_vel;
    $y += ($new_time - $old_time) * $self->y_vel;
    $self->x($x);
    $self->y($y);

    my $new = Point->new(x => $x, y => $y);


    $self->fire_event('moved', Moved->new(old => $old, new => $new));
    return 1;
}

1;
