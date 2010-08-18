package Jogo::View::FilledRect;
use mro 'c3';
use strict;
use warnings;
use SDLx::Surface;
use SDL::Rect;
use base 'Jogo::Type::Rect';

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
          ( width  => $self->{camera}->m2px($self->w),
            height => $self->{camera}->m2px($self->h),
            color  => $self->{color},
            flags => SDL_HWSURFACE,
          );
    return 1;
}

sub _init_rect {
    my ($self) = @_;
    $self->{rect_obj} =
      SDL::Rect->new
          ( 0, 0,
            $self->{camera}->m2px($self->w),
            $self->{camera}->m2px($self->h) );
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
    $self->{surface}->blit
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
