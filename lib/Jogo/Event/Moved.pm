package Jogo::Event::Moved;
use mro 'c3';
use base 'Jogo::Object';
use strict;
use warnings;

sub old {
    my $self = shift;
    $self->{old} = shift if @_;
    return $self->{old};
}

sub new {
    my $self = shift;
    $self->{new} = shift if @_;
    return $self->{new};
}

1;
