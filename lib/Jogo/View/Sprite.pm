package Jogo::View::Sprite;
use mro 'c3';
use strict;
use warnings;
use SDLx::Sprite;
use base 'Jogo::Type::Rect';

sub _init {
    my $self = shift;
    die "Need camera and main surface and image location on initialization"
      unless $self->{main} && $self->{camera} && $self->{image};
    $self->_init_surface( );
}

sub _init_surface {
    my ($self) = shift;
    $self->{surface} =
      SDLx::Sprite->new( image => $self->{image} );
    $self->{w} = $self->{surface}->surface->w;
    $self->{h} = $self->{surface}->surface->h;

    return 1;
}


sub w {
    my $self = shift;
    $self->SUPER::w(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
    }
    return $self->{w};
}

sub h {
    my $self = shift;
    $self->SUPER::h(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
    }
    return $self->{h};
}

sub render {
    my ($self) = @_;

    my $rect = SDL::Rect->new
      ( $self->{camera}->translate_x_y_w_h( $self->x, $self->y,
                                            $self->w, $self->h ) );
    $self->{surface}->surface->blit
        ( $self->{main},
          $self->{rect_obj},
          $rect );

    return 1;
}

sub zoomed_event_fired {
    my $self = shift;
    $self->_init_surface;
    $self->_init_rect;
}

sub moved_event_fired {
    my ($self, $ev) = @_;
    $self->$_($ev->new_point->$_) for
        qw(x y);
    return 1;
}


1;
