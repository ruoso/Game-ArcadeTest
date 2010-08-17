package Jogo::View::Plane;
use mro 'c3';
use strict;
use warnings;
use SDLx::Surface;
use SDL::Rect;
use base 'Jogo::Object';

sub _init {
    my $self = shift;
    die "Need camera and main surface on initialization"
      unless $self->{main} && $self->{camera} && $self->{color};
    $self->_init_surface;
    $self->_init_rect;
}

sub _init_surface {
    my ($self) = @_;
    $self->{surface} =
      SDLx::Surface->new
          ( width => $self->{camera}->w_pixels,
            height => $self->{camera}->h_pixels,
            color => $self->{color},
            flags => SDL_HWSURFACE,
          );
    return 1;
}

sub _init_rect {
    my ($self) = @_;
    $self->{rect_obj} =
      SDL::Rect->new
          ( 0, 0,
            $self->{camera}->w_pixels,
            $self->{camera}->h_pixels );
    return 1;
}

sub render {
    my ($self) = @_;

    $self->{surface}->blit
        ( $self->{main},
          $self->{rect_obj},
          $self->{rect_obj} );

    return 1;
}

1;
