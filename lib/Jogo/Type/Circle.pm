package Jogo::Type::Circle;
use mro 'c3';
use base 'Jogo::Type::Point';
use strict;
use warnings;

sub radius {
    my $self = shift;
    $self->{radius} = shift if @_;
    return $self->{radius} || 0;
}

1;

