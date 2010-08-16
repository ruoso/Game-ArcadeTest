package Jogo::Type::Point;
use mro 'c3';
use base 'Jogo::Object';
use strict;
use warnings;

sub x {
    my $self = shift;
    $self->{x} = shift if @_;
    return $self->{x} || 0;
}

sub y {
    my $self = shift;
    $self->{y} = shift if @_;
    return $self->{y} || 0;
}

1;
