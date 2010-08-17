package Jogo::Object;
use mro 'c3';
use strict;
use warnings;

sub new {
    my $self = shift;
    my $class = ref $self || $self;
    $self = bless { @_ }, $class;
    $self->_init;
    return $self;
}

sub _init {}

1;
