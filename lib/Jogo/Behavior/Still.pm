package Jogo::Behavior::Still;
use mro 'c3';
use strict;
use warnings;
use base qw(Jogo::Type::Point Jogo::Event::Observable);
use aliased 'Jogo::Type::Point';
use aliased 'Jogo::Event::Moved';

sub x {
    my $self = shift;
    if (@_) {
        my $old = Point->new(x => $self->{x}, y => $self->{y});
        $self->{x} = shift;
        my $new = Point->new(x => $self->{x}, y => $self->{y});
        $self->fire_event('moved', Moved->new(old_point => $old, new_point => $new));
    }
    return $self->{x};
}

sub y {
    my $self = shift;
    if (@_) {
        my $old = Point->new(x => $self->{x}, y => $self->{y});
        $self->{y} = shift;
        my $new = Point->new(x => $self->{x}, y => $self->{y});
        $self->fire_event('moved', Moved->new(old_point => $old, new_point => $new));
    }
    return $self->{y};
}


1;
