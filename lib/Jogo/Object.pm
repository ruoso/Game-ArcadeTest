package Jogo::Object;
use mro 'c3';
use strict;
use warnings;

sub new {
    my $self = shift;
    my $class = ref $self || $self;
    return bless { @_ }, $class;
}

1;
