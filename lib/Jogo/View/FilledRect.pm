package Jogo::View::FilledRect;
use mro 'c3';
use strict;
use warnings;
use SDL::Video ':all';
use SDL::Surface;
use SDL::Rect;
use base 'Jogo::Type::Rect';

sub _init {
    my $self = shift;
    die "Need camera and main surface on initialization"
      unless $self->{main} && $self->{camera};
    $self->_init_surface;
    $self->_init_color_object;
    $self->_init_rect;
    $self->_fill_rect;
}

sub _init_surface {
    my ($self) = @_;
    $self->{surface} =
      SDL::Surface->new
          ( SDL_HWSURFACE,
            $self->{camera}->m2px($self->w),
            $self->{camera}->m2px($self->h),
            16, 0, 0, 0, 0);
    return 1;
}

sub _init_color_object {
    my ($self) = @_;
    $self->{color_obj} =
      SDL::Video::map_RGB
          ( $self->{main}->surface->format,
            ((0xFF0000 & $self->color)>>16),
            ((0x00FF00 & $self->color)>>8),
            0x0000FF & $self->color );
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

sub _fill_rect {
    my ($self) = @_;
    SDL::Video::fill_rect
        ( $self->{surface},
          $self->{rect_obj},
          $self->{color_obj} );
    return 1;
}


sub color {
    my $self = shift;
    if (@_) {
        $self->{color} = shift;
        $self->_init_color;
        $self->_fill_rect;
    }
    return $self->{color};
}

sub w {
    my $self = shift;
    $self->SUPER::w(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
        $self->_fill_rect;
    }
    return $self->{w};
}

sub h {
    my $self = shift;
    $self->SUPER::h(@_);
    if (@_) {
        $self->_init_surface;
        $self->_init_rect;
        $self->_fill_rect;
    }
    return $self->{h};
}

sub render {
    my ($self) = @_;

    my $rect = SDL::Rect->new
      ( $self->{camera}->translate_x_y_w_h( $self->x, $self->y,
                                            $self->w, $self->h ) );
    SDL::Video::blit_surface
        ( $self->{surface},
          $self->{rect_obj},
          $self->{main},
          $rect );

    return 1;
}

sub moved_event_fired {
    my ($self, $ev) = @_;
    $self->$_($ev->new_point->$_) for
        qw(x y);
    return 1;
}


1;
