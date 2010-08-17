package Game::ArcadeTest::Model::Ball;
use mro 'c3';
use strict;
use warnings;
use base qw(Jogo::Type::Circle
            Jogo::Behavior::LinearAccelerationMovement);

use constant g => 9.8;

sub _init {
    my $self = shift;
    $self->{x} ||= 10;
    $self->{y} ||= 4;
    $self->{radius} ||= 0.5;
}

sub y_acc {
    my $self = shift;
    return $self->SUPER::y_acc(@_) - g;
}

1;
