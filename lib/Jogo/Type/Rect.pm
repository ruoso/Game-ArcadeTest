package Jogo::Type::Rect;
use base 'Jogo::Type::Point';
use strict;
use warnings;

sub w {
    my $self = shift;
    $self->{w} = shift if @_;
    return $self->{w} || 0;
}

sub h {
    my $self = shift;
    $self->{h} = shift if @_;
    return $self->{h} || 0;
}

1;

