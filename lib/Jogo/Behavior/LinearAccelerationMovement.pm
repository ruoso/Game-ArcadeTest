package Jogo::Behavior::LinearAccelerationMovement;
use strict;
use warnings;
use base 'Jogo::Behavior::LinearMovement';
use aliased 'Jogo::Type::Point';
use aliased 'Jogo::Event::Moved';

sub x_acc {
    my $self = shift;
    $self->{x_acc} = shift if @_;
    return $self->{x_acc} || 0;
}

sub y_acc {
    my $self = shift;
    $self->{y_acc} = shift if @_;
    return $self->{y_acc} || 0;
}


sub time_lapse {
    my ($self, $old_time, $new_time) = @_;
    my $elapsed = ($new_time - $old_time);

    my $x     = $self->x;
    my $x_vel = $self->x_vel;
    my $y     = $self->y;
    my $y_vel = $self->y_vel;

    my $old = Point->new(x => $x, y => $y);

    my $x_final_vel = $x_vel + $self->x_acc * $elapsed;
    my $y_final_vel = $y_vel + $self->y_acc * $elapsed;

    # trapezoid rule
    my $x_distance = (($x_vel + $x_final_vel) * $elapsed) / 2;
    my $y_distance = (($y_vel + $y_final_vel) * $elapsed) / 2;

    $x += $x_distance;
    $y += $y_distance;

    $self->x($x);
    $self->y($y);
    $self->x_vel($x_final_vel);
    $self->y_vel($y_final_vel);

    my $new = Point->new(x => $x, y => $y);

    $self->fire_event('moved', Moved->new(old => $old, new => $new));
    return 1;
}

1;
