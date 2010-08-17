package Jogo::Event::Moved;
use mro 'c3';
use base 'Jogo::Object';
use strict;
use warnings;

sub old_point {
    my $self = shift;
    $self->{old_point} = shift if @_;
    return $self->{old_point};
}

sub new_point {
    my $self = shift;
    $self->{new_point} = shift if @_;
    return $self->{new_point};
}

1;
