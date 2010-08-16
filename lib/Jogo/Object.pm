package Jogo::Object;
use strict;
use warnings;

sub new {
    my $self = shift;
    my $class = ref $self || $self;
    return bless { @_ }, $class;
}

1;
